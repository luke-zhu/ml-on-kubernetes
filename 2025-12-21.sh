kubectl create namespace shuzijihechuli

cd 001C-registry
helm --kube-context desktop upgrade --install pull-registry ./docker-registry \
    --namespace shuzijihechuli \
    --values pull-registry-values.yaml
helm --kube-context desktop upgrade --install push-registry ./docker-registry \
    --namespace shuzijihechuli \
    --values push-registry-values.yaml

# Outside in the node itself.
# sudo vim /etc/docker/daemon.json
# {
#   "insecure-registries": ["10.0.0.50:32020", "10.0.0.50:32021"],
#   "registry-mirrors": []
# }
# sudo vim /etc/rancher/k3s/registries.yaml
# mirrors:
#   "10.0.0.50:32020":
#     endpoint:
#       - "http://10.0.0.50:32020"
#   "10.0.0.50:32021":
#     endpoint:
#       - "http://10.0.0.50:32021"
# sudo systemctl restart docker
# sudo systemctl restart k3s.service

cd 001E-devenv
sudo docker build . --tag localhost:32021/devenv:latest
sudo docker push localhost:32021/devenv:latest
kubectl --namespace shuzijihechuli create secret generic dev \
    --from-file=authorized_keys=/home/dev/.ssh/authorized_keys
kubectl --namespace shuzijihechuli create configmap kube-config --from-file=config=/home/dev/.kube/config
kubectl --namespace shuzijihechuli apply -f devenv.yaml

# Outside in the node itself.
# ssh -o StrictHostKeyChecking=no dev@10.0.0.50  -p 30019
