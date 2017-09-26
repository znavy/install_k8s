KUBELET_ADDRESS="--address=NODE_HOST"
KUBELET_PORT="--port=10250"
KUBELET_HOSTNAME="--hostname-override=NODE_HOST"
KUBELET_API_SERVER="--api-servers=https://K8S_MASTER_LVS:6443"
KUBELET_PAUSE_IMAGE="--pod-infra-container-image=PRI_DOCKER_HOST:5000/google-containers/pause-amd64:3.0"
KUBELET_CLUSTER_DOMAIN="--cluster-domain=cluster.local"
KUBELET_CLUSTER_DNS="--cluster-dns=192.168.0.2"
KUBELET_ARGS="--max-pods=300 --kubeconfig=/etc/kubernetes/kubelet.conf --require-kubeconfig=true --pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true --authorization-mode=Webhook --client-ca-file=/etc/kubernetes/pki/ca.pem --tls-cert-file=/etc/kubernetes/pki/kubelet.pem --tls-private-key-file=/etc/kubernetes/pki/kubelet-key.pem"
