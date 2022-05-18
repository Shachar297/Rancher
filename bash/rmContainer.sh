rancherDockerContainerID=$(docker ps -q --filter ancestor=rancher/rancher:$tag)

docker stop $rancherDockerContainerID && docker rm $rancherDockerContainerID