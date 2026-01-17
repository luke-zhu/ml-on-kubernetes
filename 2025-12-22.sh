
cd 001E-devenv
kubectl create namespace shuzijihe-test
sudo docker build . --tag localhost:32021/devenv:latest
sudo docker push localhost:32021/devenv:latest
kubectl --namespace shuzijihe-test apply -f devenv.yaml
kubectl --namespace shuzijihe-test apply -f devenv.yaml
