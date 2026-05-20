#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Initialize conda
eval "$(conda shell.bash hook)"

# Create environment
conda create --name suno-analytics python=3.9 -y

# Activate environment
conda activate suno-analytics

# Install core packages
conda install -c conda-forge \
    pandas \
    plotly \
    scikit-learn \
    matplotlib \
    jupyterlab \
    nb_conda \
    nodejs \
    ipykernel \
    -y

# Install pip packages
pip install -r requirements.txt

# Setup Jupyter kernel
python -m ipykernel install --user --name suno-analytics --display-name "Suno Analytics"
