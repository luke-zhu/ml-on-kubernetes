# helm install ./002-mlflow
#     --values

ALL_PROXY=socks5://10.0.0.50:21080
HTTP_PROXY=socks5://10.0.0.50:21080
HTTPS_PROXY=socks5://10.0.0.50:21080
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update
helm pull nvidia/nvidia-device-plugin --untar
helm --namespace shuzijihechuli \
    upgrade -i nvidia-device-plugin \
    nvidia/nvidia-device-plugin
helm --namespace shuzijihechuli uninstall  nvidia-device-plugin


# https://github.com/NVIDIA/k8s-device-plugin#quick-start
# sudo nvidia-ctk runtime configure --runtime=containerd
sudo cat /etc/containerd/conf.d/99-nvidia.toml
sudo cat /var/lib/rancher/k3s/agent/etc/containerd/config.toml

# sudo vim /var/lib/rancher/k3s/agent/etc/containerd/config-v3.toml.tmpl
# {{ template "base" . }}

# [plugins."io.containerd.grpc.v1.cri".containerd.runtimes."nvidia"]
#   privileged_without_host_devices = false
#   runtime_engine = ""
#   runtime_root = ""
#   runtime_type = "io.containerd.runc.v2"

# [plugins."io.containerd.grpc.v1.cri".containerd.runtimes."nvidia".options]
#   BinaryName = "/usr/bin/nvidia-container-runtime"
#   Runtime = "/usr/bin/nvidia-container-runtime"
sudo systemctl restart k3s.service

cd 001E-devenv
sudo docker build . --tag localhost:32021/devenv:latest
sudo docker push localhost:32021/devenv:latest
kubectl --namespace shuzijihe-test create secret generic dev \
    --from-file=authorized_keys=/home/dev/.ssh/authorized_keys
kubectl --namespace shuzijihe-test create configmap kube-config --from-file=config=/home/dev/.kube/config
kubectl --namespace shuzijihe-test apply -f devenv-copy-12-28.yaml
kubectl --namespace shuzijihe-test exec -it dev-0 -- /bin/bash


kubectl --namespace shuzijihechuli apply -f devenv.yaml
kubectl --namespace shuzijihechuli delete pod dev-0


helm install mlflow  ./002-mlflow  \
    --namespace shuzijihechuli \
    --values mlflow-values.yaml

helm install seaweedfs  ./002C-seaweedfs  \
    --namespace shuzijihechuli \
    --values seaweedfs-values.yaml

weed shell -master=seaweedfs-master:9333 -filer=localhost:8888
# >s3.bucket.create -name wandb

helm upgrade --namespace shuzijihechuli \
    --install wandb ./003-wandb \
    --values wandb-values.yaml
