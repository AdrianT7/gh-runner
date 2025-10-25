This document describes the repository's CI/CD pipelines, triggers, jobs, secrets, outputs and maintenance notes.

## Workflows:
### [`Build and push image to Dockerhub`](build_and_push_image.yml)

Basic info
- Purpose: Build and publish a Docker image for the self-hosted GitHub Actions runner and push to Docker Hub.
- Primary workflow: [`Build and push image to Dockerhub`](build_and_push_image.yml)

Trigger events
- Trigger: pull_request closed on branch `main` affecting the `VERSION` file
  - See the `on:` section in [build_and_push_image.yml](build_and_push_image.yml)
- Conditional publishing: the job runs only when the PR is merged into `main` (`if: github.event.pull_request.merged == true && github.event.pull_request.base.ref == 'main'`).

Branches & paths filtered
- Branch: `main`
- Path: `VERSION` (only changes to this file trigger the workflow)
- See the top of [build_and_push_image.yml](build_and_push_image.yml).

Dependencies between workflows
- No other workflows in this repo reference or depend on this workflow.
- The workflow itself creates a Kubernetes Job that performs the build inside the cluster using Kaniko (`image-builder/release-image-job.yml`).

Jobs & steps (high level)
- Job: `release` (runs on self-hosted Linux runner)
  - Checkout repo — `uses actions/checkout`
  - Read version from `VERSION` and set $VERSION
  - Replace `__image_tag__` placeholder in `image-builder/release-image-job.yml`
  - Authenticate kubectl using secret `KUBECTL_CRED`
  - Create namespace `image-builder/namespace.yml`
  - Create `github-pat` Kubernetes secret (from `GH_PAT`)
  - Create `docker-hub-cred` K8s secret (from `DOCKER_HUB_CRED` base64)
  - Launch Kaniko job: `kubectl create -f image-builder/release-image-job.yml`
  - Cleanup kubeconfig
- Order and purpose are in the steps block of `build_and_push_image.yml`

Key steps
- Build: Kaniko runs inside K8s using `image-builder/release-image-job.yml` to build image from the repository Dockerfile.
- Push: Kaniko pushes image to Docker Hub destinations defined in the Kaniko args (e.g. `adriant7/gh-runner:latest` and `adriant7/gh-runner:__image_tag__`).
- Notifications / approvals: None implemented in current workflow (no required reviewers / manual approvals).
- Conditional triggers: `if: github.event.pull_request.merged == true && github.event.pull_request.base.ref == 'main'` is used to ensure publish happens only for merged PRs to main.

Artifacts & outputs
- Artifacts produced:
  - Docker images pushed to Docker Hub (image names configured inside `image-builder/release-image-job.yml`. Example: `adriant7/gh-runner:1.4.0` (tag from `VERSION`)
- Storage:
  - Images are stored at Docker Hub. No GitHub Actions artifact uploads are used.

Secrets & environment
- Secrets used by the workflow:
  - `KUBECTL_CRED` — base64 Kubeconfig used to run kubectl (set in repository secrets). Used in the "Authenticate into cluster" step.
  - `GH_PAT` — GitHub personal access token injected into Kubernetes as `github-pat` secret for Kaniko to fetch the repository (see `image-builder/release-image-job`).
  - `DOCKER_HUB_CRED` — base64-encoded docker config.json used to create K8s secret `docker-hub-cred` so Kaniko can push to Docker Hub.
- Environment variables:
  - `IMAGE` (set to `${{ github.repository }}` in workflow env)
  - `VERSION` (set at runtime from `VERSION` — used to replace `__image_tag__` in the Kaniko job).
---