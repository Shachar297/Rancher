installRancher() {
    docker run -d --restart=unless-stopped \
        -p 8081:8080 -p 443:443 \
        --privileged \
        rancher/rancher:latest
}

installRancherServer() {
    docker run -d \
        --restart=unless-stopped \
        -p 8080:8080 \
        rancher/server
}

curl -sfL https://get.rke2.io --output install.sh && \
    chmod +x install.sh && \
    response=$(sudo ./install.sh)

    if [[ $response == *"failed to connect to bus" ]]; then
    ./fixHostError.sh
    fi

# sudo systemctl enable rke2-server.service && \
#     sudo systemctl start rke2-server.service &

# installRancher

# helm repo add rancher-latest https://releases.rancher.com/server-charts/latest && \
#     kubectl create namespace cattle-system


