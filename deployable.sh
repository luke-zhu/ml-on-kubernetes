# First configure a Kubernetes console in aliyun ACK
# https://csnew.console.aliyun.com/#/k8s/cluster/createV2/managed/autoMode?region=cn-beijing&template=pro-standard

# Then run the following commands

LICENSE_STRING="<YOUR_WANDB_LICENSE>"

helm install mlflow  ./002-mlflow  \
    --values mlflow-values.yaml

helm install wandb  ./003-wandb  \
    --values wandb-values.yaml
    --set license="$LICENSE_STRING"
