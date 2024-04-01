Build docker image in gitlab-ci
``` shell
export VERSION="8.0.29"
export IMAGE_NAME="mysql"
echo "FROM ${IMAGE_NAME}:${VERSION}" > Dockerfile.${IMAGE_NAME}
docker build --no-cache --tag "${IMAGE_NAME}:${VERSION}" --file Dockerfile.${IMAGE_NAME} .
```