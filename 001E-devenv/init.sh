#!/usr/bin/bash
set -e
set -o pipefail

chown dev:dev /home/dev
chmod 755 /home/dev/

# # Make it possible to SSH into the pod
mkdir -p /home/dev/.ssh/

if ! grep -qFxf /etc/shuzijihechuli/dev/authorized_keys /home/dev/.ssh/authorized_keys; then
    cat /etc/shuzijihechuli/dev/authorized_keys >> /home/dev/.ssh/authorized_keys
fi

chown -R dev:dev /home/dev/.ssh/

touch /home/dev/.kube/config-custom
chown dev:dev /home/dev/.kube
chown dev:dev /home/dev/.kube/config-custom

su dev <<EOT

if command -v conda; then
    wget https://repo.anaconda.com/miniconda/Miniconda3-py313_25.11.1-1-Linux-x86_64.sh \
    && echo "e0b10e050e8928e2eb9aad2c522ee3b5d31d30048b8a9997663a8a460d538cef  Miniconda3-py313_25.11.1-1-Linux-x86_64.sh" | sha256sum -c \
    && bash Miniconda3-py313_25.11.1-1-Linux-x86_64.sh -b \
    && rm Miniconda3-py313_25.11.1-1-Linux-x86_64.sh
    /home/dev/miniconda3/bin/conda init
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
fi

conda create --name nerfstudio -y python=3.8
conda activate nerfstudio
pip install --upgrade pip

pip install torch==2.1.2+cu118 torchvision==0.16.2+cu118 --extra-index-url https://download.pytorch.org/whl/cu118
conda install -c "nvidia/label/cuda-11.8.0" cuda-toolkit
pip install ninja git+https://github.com/NVlabs/tiny-cuda-nn/#subdirectory=bindings/torch
pip install nerfstudio

EOT