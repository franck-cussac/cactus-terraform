#!/usr/bin/env bash
### ECR - build images and push to remote repository

eval $(aws ecr get-login --no-include-email)

# tag and push image using latest
docker tag franckcussac/frontend $AWS_ACCOUNT.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/cactus-frontend:latest
docker tag franckcussac/backend $AWS_ACCOUNT.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/cactus-backend:latest
docker push $AWS_ACCOUNT.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/cactus-frontend:latest
docker push $AWS_ACCOUNT.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/cactus-backend:latest
