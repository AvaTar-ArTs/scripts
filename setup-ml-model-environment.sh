#!/usr/bin/env bash
# ==========================================
# Intel macOS ML Models Setup Script
# ==========================================

# Exit on error
set -e

echo "🔧 Installing prerequisites..."

# Ensure Homebrew is installed
if ! command -v brew &> /dev/null; then
  echo "Homebrew not found, installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update brew and install essentials
brew update
brew install python git wget

# Create virtual environment
echo "📦 Setting up Python virtual environment..."
PY_ENV="$HOME/mlmodels_env"
python3 -m venv $PY_ENV
source $PY_ENV/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install core ML packages (Intel-optimized Torch)
echo "📥 Installing PyTorch (CPU, Intel macOS)..."
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu

# Install Hugging Face ecosystem
echo "📥 Installing Hugging Face libraries..."
pip install transformers accelerate datasets huggingface-hub sentencepiece

# Optional: safetensors for efficient model weights
pip install safetensors

# Download models (only configs/weights, not full inference run yet)
echo "📥 Downloading model configs from Hugging Face..."

python <<'PYCODE'
from huggingface_hub import snapshot_download

models = {
    "llama-3.2-3b": "meta-llama/Llama-3.2-3B",
    "phi3-mini-3.8b": "microsoft/phi-3-mini-3.8b",
    "smollm2-1.7b": "HuggingFaceTB/SmolLM2-1.7B",
    "mistral-7b": "mistralai/Mistral-7B-v0.1",
    "qwen2.5-coder-3b": "Qwen/Qwen2.5-Coder-3B"
}

for name, repo in models.items():
    print(f"⬇️ Downloading {name} from {repo}...")
    snapshot_download(repo_id=repo, local_dir=f"./models/{name}", ignore_patterns=["*.safetensors.index.json"])
PYCODE

echo "✅ Setup complete! To start using models, run:"
echo "---------------------------------------------------"
echo "source $PY_ENV/bin/activate"
echo "python"
echo ">>> from transformers import AutoModelForCausalLM, AutoTokenizer"
echo ">>> tok = AutoTokenizer.from_pretrained('./models/llama-3.2-3b')"
echo ">>> model = AutoModelForCausalLM.from_pretrained('./models/llama-3.2-3b')"
echo "---------------------------------------------------"
