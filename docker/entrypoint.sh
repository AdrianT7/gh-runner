#!/bin/bash
./config.sh --url $GH_REPO_URL --token $GH_RUNNER_TOKEN --name $GH_RUNNER_NAME --runnergroup $GH_RUNNER_GROUP --work $GH_RUNNER_WORK_DIR --labels $GH_RUNNER_LABELS
exec ./run.sh