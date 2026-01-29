
# Minimal Docker image for DINCAE.jl
FROM nvidia/cuda:12.6.0-cudnn-runtime-ubuntu22.04

# Install Julia and dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Julia 1.10
RUN curl -fsSL https://install.julialang.org | sh -s -- --yes
ENV PATH="/root/.juliaup/bin:${PATH}"

# Set working directory
WORKDIR /app

# Copy project files
COPY Project.toml ./
COPY examples/Project.toml ./examples/

# Copy the rest of the application
COPY . .

# Set working directory for running scripts
WORKDIR /app/examples

# Pre-install Julia packages
RUN julia -e 'using Pkg; \
    Pkg.add(url="https://github.com/gher-uliege/DINCAE.jl", rev="main"); \
    Pkg.add(url="https://github.com/gher-uliege/DINCAE_utils.jl", rev="main"); \
    Pkg.add(["CUDA", "cuDNN", "NCDatasets", "PyPlot", "Dates"]); \
    Pkg.precompile()'

# Copy the rest of the application
COPY . .

# Set working directory for running scripts
WORKDIR /app/examples

CMD ["julia", "--project=.", "DINCAE_tutorial.jl"]