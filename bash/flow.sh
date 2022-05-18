# ----- variables ----->

kubeDirectory=k8s
NAMESPACE=rancher
images=("busybox", "nginx", "ubuntu")
helmDestination="/usr/local/bin/helm/"
imageDestination=""
clusterUser=""
clusterAddress=""
rancherDockerContainerID=$(docker ps -q --filter ancestor=rancher/rancher:latest)
# ----- functions ---->
installRancher() {
    docker run -d --restart=unless-stopped \
    -p 80:80 -p 8443:443 \
    --privileged \
    rancher/rancher:v2.4.18
}


createLocalRegistry () {
    docker  run \
        -d \
        -p 5001:5000 \
        --restart always \
        --name registry \
        registry:latest
}

pullImagesFromRegistry () {

    mkdir images

for image in "${images[@]}"
do
    docker pull "${image//,}"
    docker tag "${image//,}" localhost:5001/"${image//,}"
    docker push localhost:5001/"${image//}"
    docker save localhost:5001/"${image//}" >>  images/"localhost:5001/${image//}"
done

    docker save registry >> images/registry
    

}

removeOutputs() {
if [[ -f $kubeDirectory/output.yml ]]; then
rm $kubeDirectory/output.yml
fi
}

createDeployment() {
kubectl kustomize $kubeDirectory/ >> $kubeDirectory/output.yml && \
    kubectl apply -f $kubeDirectory/output.yml && \
    kubectl get ns $NAMESPACE 
}


# getHelm() {

# echo "--------- Installing Helm..."

# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
# chmod 700 get_helm.sh \
#     ./get_helm.sh
# }

copyImagesFromLocalToTheCluster() {

    sudo docker cp $helmDestination "${rancherDockerContainerID}":"${helmDestination}"
    sudo docker cp ./images/* "${rancherDockerContainerID}":/var/
    sudo docker cp ./charts/*.tgz "${rancherDockerContainerID}":/var/

    for image in "${images[@]}"
        do
            docker pull "${image//,}"
            docker tag "${image//,}" localhost:5000/"${image//,}"
            docker push localhost:5000/"${image//}"
            docker save localhost:5000/"${image//}" >>  images/"localhost:5000/${image//}"
        done
}


installServicesOnCluster() {

    kubectl create ns $NAMESPACE


for i in charts/*.tgz; do

    [ -f "$i" ] || break
    fileName=$(echo $i | cut -d'/' -f 2)
    imageName=$(echo $fileName | cut -d'-' -f 1)
    helm install $imageName $fileName -n $NAMESPACE

done

}
 

# <-------- functions end



# Flow Begins ----- >

installRancher
createLocalRegistry
pullImagesFromRegistry
removeOutputs
createDeployment
getHelm
copyImagesFromLocalToTheCluster
installServicesOnCluster

# <----- Flow Ends ----- >

