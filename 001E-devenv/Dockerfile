FROM docker.m.daocloud.io/nvidia/cuda:12.9.1-cudnn-devel-ubuntu22.04

# Unminimize
RUN yes | unminimize && apt-get install -yqq man-db

# Create the admin user 'dev' and install a few key packages to be used in the following steps.
# Rest of useradd steps are in init.sh
RUN apt-get update -yqq \
    && apt-get install -yqq \
    openssh-server \
    sudo \
    curl \
    apt-transport-https \
    ca-certificates \
    gnupg-agent \
    software-properties-common

RUN sed -i -E 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    useradd --shell "/usr/bin/bash" dev \
    && usermod -aG sudo dev \
    && echo "dev:dev" | chpasswd \
    && newgrp sudo

# Install git and the GitHub plugin
RUN apt-get install -yqq git \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt-get update \
    && sudo apt-get install -yqq gh

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/v1.29.1/bin/linux/amd64/kubectl" \
    && curl -LO "https://dl.k8s.io/release/v1.29.1/bin/linux/amd64/kubectl.sha256" \
    && echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl kubectl.sha256

# curl -fsSL https://download.docker.com/linux/ubuntu/gpg
COPY docker_gpg.txt docker_gpg.txt

# Install Docker CLI
RUN install -m 0755 -d /etc/apt/keyrings \
    && cat docker_gpg.txt | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && sudo chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -yqq docker-ce-cli 

# Install utilities (part 1)

RUN apt-get install -yqq \
    make \
    vim \
    nano \
    bash-completion \
    ripgrep \
    jq \
    zip \
    zstd
    
# Install node
# TODO: sync node versions 003-suggest and 001-devenv
RUN curl -sL https://deb.nodesource.com/setup_22.x | bash \
    && sudo apt-get install -y nodejs

# Install Go
RUN wget https://golang.google.cn/dl/go1.22.5.linux-amd64.tar.gz \
    && echo "904b924d435eaea086515bc63235b192ea441bd8c9b198c507e85009e6e4c7f0  go1.22.5.linux-amd64.tar.gz" | sha256sum --check \
    && tar -xzf go1.22.5.linux-amd64.tar.gz -C /usr/local \
    && rm go1.22.5.linux-amd64.tar.gz

# Install new utilities here (part 2)
# Move packages up to the other "Install utilities" section above when this step gets too slow.
# RUN apt-get install -yqq ...

RUN apt-get install -yqq htop dnsutils

# export ALL_PROXY=socks5://10.0.0.50:21080
# export HTTP_PROXY=socks5://10.0.0.50:21080
# export HTTPS_PROXY=socks5://10.0.0.50:21080
# curl -O https://get.helm.sh/helm-v3.15.3-linux-amd64.tar.gz
COPY helm-v3.15.3-linux-amd64.tar.gz helm-v3.15.3-linux-amd64.tar.gz

RUN echo "ad871aecb0c9fd96aa6702f6b79e87556c8998c2e714a4959bf71ee31282ac9c helm-v3.15.3-linux-amd64.tar.gz" | sha256sum --check \
    && tar -xzf helm-v3.15.3-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin \
    && rm -r linux-amd64/ helm-v3.15.3-linux-amd64.tar.gz

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PYTHONUNBUFFERED=1
ENV UV_SYSTEM_PYTHON=1
ENV UV_NO_BINARY=torch,torchvision,torchaudio,pytorch3d

### BEGIN: DeepSeek nerfstudio install

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    git \
    curl \
    build-essential \
    software-properties-common \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libx11-6 \
    ffmpeg \
    libavcodec-extra \
    libopencv-dev \
    python3-opencv \
    python3-dev \
    python3-pip \
    ninja-build \
    freeglut3-dev \
    cmake \
    pkg-config \
    libjpeg-dev \
    libtiff-dev \
    libpng-dev \
    libopenblas-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer1.0-dev \
    && rm -rf /var/lib/apt/lists/*

# Create a symbolic link for python3 -> python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install uv (modern Python package installer)
RUN pip3 install uv

# Create workspace directory
WORKDIR /workspace

# Copy requirements files
COPY requirements.txt ./

# Install Python dependencies with uv
RUN uv pip install \
    --system \
    --no-cache \
    --requirement requirements.txt

### END: DeepSeek nerfstudio install


ADD .bashrc .bashrc
ADD .complete_alias .complete_alias
ADD init.sh init.sh

# All 'su - dev' to work in init.sh without a password
RUN echo '%dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && echo 'root ALL=NOPASSWD: /bin/su - dev' >> /etc/sudoers

CMD sudo /etc/init.d/ssh start \
    && cp .bashrc /home/dev/.bashrc \
    && chown dev:dev /home/dev/.bashrc \
    && cp .complete_alias /home/dev/.complete_alias \
    && chown dev:dev /home/dev/.complete_alias \
    && ./init.sh \
    && sleep infinity
