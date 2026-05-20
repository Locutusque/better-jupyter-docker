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
RUN apt-get install -y cuda-toolkit-12-8 && \
    ln -s /usr/local/cuda-12.8 /usr/local/cuda || true

# ----------------------------
# 4. Environment variables (apply to ALL users via /etc/environment)
# ----------------------------
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=/usr/local/cuda/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Write into jovyan's shell profile so interactive/non-login shells also pick it up
RUN echo 'export CUDA_HOME=/usr/local/cuda' >> /home/jovyan/.bashrc && \
    echo 'export PATH=/usr/local/cuda/bin:$PATH' >> /home/jovyan/.bashrc && \
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> /home/jovyan/.bashrc

# Also write to /etc/profile.d so it applies system-wide for all login shells
RUN echo 'export CUDA_HOME=/usr/local/cuda' > /etc/profile.d/cuda.sh && \
    echo 'export PATH=/usr/local/cuda/bin:$PATH' >> /etc/profile.d/cuda.sh && \
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> /etc/profile.d/cuda.sh

# ----------------------------
# 5. Switch to jovyan and pre-build flash-attn
# ----------------------------
USER jovyan

RUN nvcc --version
