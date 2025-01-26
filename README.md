# gh-runner - GitHub Actions Self-Hosted Runner with Docker

This repository provides an easy way to set up and run a self-hosted GitHub Actions runner using Docker and Docker Compose. The configuration is managed via **docker-compose.yml** and **.env** file, allowing you to quickly provide required parameters such as tokens and repository details.

---

## Features
- **Self-hosted GitHub Actions runner**: Run workflows on your own infrastructure.
- **Dockerized setup**: Easy deployment and management with Docker Compose.
- **Scalable**: Configure multiple runners using one token.
- **Token management**: Clear instructions for handling GitHub tokens.

---

## Requirements
- *Docker* and *Docker Compose* installed on your host machine.
- GitHub personal access token with permissions to manage runners.
- A repository or organization where you want to add runners.

---

## 3 Easy steps to deploy your brand new GitHub Actions self hosted runner:

### 1. Clone the repository 
   Clone this repository to your host machine with Docker installed and change your current working directory to `docker`.
    
   ```bash
   git clone https://github.com/AdrianT7/gh-runner.git
   cd gh-runner/docker
   ```

### 2. Fill in the `docker/.env` file
   Add the necessary configuration parameters (token and repository url) to the `.env` file.

   ```bash
      GH_RUNNER_TOKEN="<your_github_runner_token>"
      GH_REPO_URL="<your_repository_url>"
   ```


   Adjust number of runners in `docker-compose.yml` - default number is 2

3. ###Deploy your runner(s)
   Inside `docker` directory use:
   `docker-compose up -d`

   Verify that the runners are successfully registered in your GitHub repository under:
   - Settings > Actions > Runners.

---

## Token management
*Token expiration:* Tokens are valid for 1 hour only. If the token expires, you will need to generate a new one to register a new runner.
You can register multiple runners using one token.
After a runner is registered, it remains active until manually removed.

## Troubleshooting
*Token expired during setup of a new runner*

Regenerate the token in your repository settings:
- In your repository go to Settings > Actions > Runners.

Generate a new registration token.
- Update `GH_RUNNER_TOKEN=""` in `.env` file.

Restart your runners using:
- `docker-compose down && docker-compose up -d`

### Note, that this will recreate all your gh-runner containers.
Delete *offline* runner(s) from your repository: 
- Settings > Actions > Runners > Remove runner