ALL_PROXY=socks5://10.0.0.50:21082
HTTP_PROXY=socks5://10.0.0.50:21082
HTTPS_PROXY=socks5://10.0.0.50:21082

helm repo add seldonio https://storage.googleapis.com/seldon-charts
helm repo update

helm repo add heartex https://charts.heartex.com/
helm repo update heartex

helm install <RELEASE_NAME> heartex/label-studio -f ls-values.yaml


helm repo add nfs-ganesha-serveimr-and-external-provisioner https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/
helm search repo nfs-ganesha-server-and-external-provisioner
helm pull nfs-ganesha-server-and-external-provisioner/nfs-server-provisioner --untar
mv nfs-server-provisioner 001X-nfs-server-provisioner

git clone https://github.com/cvat-ai/cvat.git
cp -r cvat/helm-chart/ 004-cvat/
cd ./004-cvat/
helm dependency build
cd ..

helm   -n shuzijihechuli \
  uninstall cvat
helm upgrade --install cvat \
  ./004-cvat/ \
  -n shuzijihechuli \
  -f cvat-values.yaml

HELM_RELEASE_NAMESPACE="shuzijihechuli" &&\
HELM_RELEASE_NAME="cvat" &&\
BACKEND_POD_NAME=$(kubectl get pod --namespace $HELM_RELEASE_NAMESPACE -l tier=backend,app.kubernetes.io/instance=$HELM_RELEASE_NAME,component=server -o jsonpath='{.items[0].metadata.name}') &&\
kubectl exec -it --namespace $HELM_RELEASE_NAMESPACE $BACKEND_POD_NAME -c cvat-backend -- python manage.py createsuperuser
