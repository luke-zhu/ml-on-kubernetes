# First configure a Kubernetes console in aliyun ACK
# https://csnew.console.aliyun.com/#/k8s/cluster/createV2/managed/autoMode?region=cn-beijing&template=pro-standard

# Then run the following commands

LICENSE_STRING="<YOUR_LICENSE_STRING>"



NAMESPACE=shuzijihechuli

kubectl create ns $NAMESPACE || true

helm upgrade --install mlflow  ./002-mlflow  \
    --namespace $NAMESPACE \
    --values mlflow-values.yaml

helm upgrade --install wandb  ./003-wandb  \
    --values wandb-values.yaml \
    --namespace $NAMESPACE \
    --set license="$LICENSE_STRING"
