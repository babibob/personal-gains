# Remove all daemon-created docker containers
docker ps -aqf "name=[a-z]_[a-z]" | xargs docker rm {}

# Clean all unused dockerd images
docker system prune -f && \
docker builder prune --all -f

# Clean all unused dockerd volumes
docker volume prune -f && docker volume rm $(docker volume ls -q -f dangling=true) && \
docker image prune -a

# Show runnind docker images
docker ps -a --format 'table {{.Names | printf "%-30.30s"}} {{.Status | printf "%-30.30s"}} {{.Ports}}'

# Show and sort local docker images
docker images --format 'table {{.Repository | printf "%-50.50s"}}\t{{.ID}}\t{{.Size}}' | sort -k 3 -h
# OR
docker images | sort -k7 -h

# Install docker
curl -o - https://get.docker.com | bash -

# Show docker compose files names and full path
for c in `docker ps -q`; \
    do docker inspect $c --format '{{ .Config.Labels.containers | printf "%-30.30s"}} {{index .Config.Labels "com.docker.compose.project.config_files"}}' ; \
done
# OR Show location of docker compose files directory
for c in `docker ps -q`; \
    do docker inspect $c --format '{{ .Config.Labels.containers | printf "%-30.30s"}} {{index .Config.Labels "com.docker.compose.project.working_dir"}}' ; \
done

# Show container IP address
for c in `docker ps -q`; do docker inspect  -f '{{ .Config.Labels.containers | printf "%-30.30s"}} {{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $c ; done
#OR
docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}:::{{.IPAddress}}{{end}}' $(docker ps -aq)

# Build docker image in gitlab-ci
export VERSION="8.0.29"
export IMAGE_NAME="mysql"
echo "FROM ${IMAGE_NAME}:${VERSION}" > Dockerfile.${IMAGE_NAME}
docker build --no-cache --tag "${IMAGE_NAME}:${VERSION}" --file Dockerfile.${IMAGE_NAME} .
