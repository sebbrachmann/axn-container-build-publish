#!/bin/sh

# exit when any command fails
set -e

# check inputs
# GITHUB_REPOSITORY environment variable will be provided by the environment automatically
if [[ -z "$GITHUB_TOKEN" ]]; then
	echo "Set the environment variable GITHUB_TOKEN."
	exit 1
fi

if [[ -z "$INPUT_IMAGE_NAME" ]]; then
	echo "Set the IMAGE_NAME input."
	exit 1
fi

if [[ -z "$INPUT_DOCKERFILE_PATH" ]]; then
	echo "Set the DOCKERFILE_PATH input."
	exit 1
fi

if [[ -z "$INPUT_BUILD_CONTEXT" ]]; then
	echo "Set the BUILD_CONTEXT input."
	exit 1
fi

if [[ -z "$INPUT_TAG" ]]; then
	echo "Set the INPUT_TAG input."
	exit 1
fi

# send credentials through stdin
user=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/user | jq -r .login)
# lowercase the username
username="$(echo ${user} | tr "[:upper:]" "[:lower:]")"
echo ${GITHUB_TOKEN} | docker login docker.pkg.github.com -u "${username}" --password-stdin 

# Set Local Variables, lowering case to make it work
tag="$(echo ${GITHUB_REPOSITORY} | tr "[:upper:]" "[:lower:]")"
CONTAINER_NAME="docker.pkg.github.com/${tag}/${INPUT_IMAGE_NAME}:${INPUT_TAG}"

# Build The Container
docker build -t ${CONTAINER_NAME} -f ${INPUT_DOCKERFILE_PATH} ${INPUT_BUILD_CONTEXT}
docker push ${CONTAINER_NAME}

echo "::set-output name=IMAGES_LINK::https://github.com/${GITHUB_REPOSITORY}/packages"
echo "::set-output name=IMAGE_URL::${CONTAINER_NAME}"
