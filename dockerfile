FROM quay.io/jupyter/pytorch-notebook:cuda12-python-3.11.8

USER root
ENV DEBIAN_FRONTEND=noninteractive

# ----------------------------
# 1. Base dependencies
# ----------------------------
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    software-properties-common \
    build-essential \
    ninja-build \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------
# 2. Install CUDA repo (Ubuntu 24.04 compatible method)
# ----------------------------
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    apt-get update

# ----------------------------
# 3. Install CUDA Toolkit 12.8 (includes NVCC)
# ----------------------------
RUN apt-get install -y cuda-toolkit-12-8

# ----------------------------
# 4. Environment variables
# ----------------------------
ENV CUDA_HOME=/usr/local/cuda-12.8
ENV PATH=$CUDA_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

# ----------------------------
# 5. Switch back to Jupyter user
# ----------------------------
USER jovyan

# ----------------------------
# 6. Verify NVCC exists
# ----------------------------
RUN nvcc --version