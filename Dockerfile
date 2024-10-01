# Stage 1: Base image with common dependencies
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 as base

# Prevents prompts from packages asking for user input during installation
ENV DEBIAN_FRONTEND=noninteractive
# Prefer binary wheels over source distributions for faster pip installations
ENV PIP_PREFER_BINARY=1
# Ensures output from python is printed immediately to the terminal without buffering
ENV PYTHONUNBUFFERED=1 

# Install Python, git and other necessary tools
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    wget

# Clean up to reduce image size
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Clone ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui

# Change working directory to ComfyUI
WORKDIR /comfyui

# Install ComfyUI dependencies
RUN pip3 install --upgrade --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
    && pip3 install --upgrade -r requirements.txt

# Install runpod
RUN pip3 install runpod requests

# Support for the network volume
ADD src/extra_model_paths.yaml ./

# Install custom nodes
WORKDIR /comfyui/custom_nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git && \
    git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git && \
    git clone https://github.com/mav-rik/facerestore_cf.git && \
    git clone https://github.com/k-komarov/comfyui-bunny-cdn-storage.git && \
    git clone https://github.com/Gourieff/comfyui-reactor-node.git
RUN cd comfyui-bunny-cdn-storage && pip3 install -r requirements.txt && cd .. && \
    cd facerestore_cf && pip3 install -r requirements.txt && cd .. && \
    cd comfyui-reactor-node && pip3 install -r requirements.txt && python3 install.py && cd ..

# Go back to the root
WORKDIR /

# Add the start and the handler
ADD src/start.sh src/rp_handler.py test_input.json ./
RUN chmod +x /start.sh

# Stage 3: Final image
FROM base as final

# Start the container
CMD ["/start.sh"]
