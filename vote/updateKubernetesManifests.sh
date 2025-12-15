#!/bin/bash

set -x

REPO_URL="https://ASeWGIr8gxBBalk6gIiualpcQQnN7ZPPdVuSTGM3tabx8sIM4C43JQQJ99BLACAAAAACh5bkAAASAZDO2kiO@dev.azure.com/a-agboola/votingApp/_git/votingApp"

git clone "$REPO_URL" /tmp/temp_repo

cd /tmp/temp_repo

sed -i "s|image:.*|image: myVotingAppContainerRegistry/${2}:${3}|g" k8s-specifications/${1}-deployment.yaml

git add .

git commit -m "Update Kubernetes Manifest"

git push

rm -rf /tmp/temp_repo