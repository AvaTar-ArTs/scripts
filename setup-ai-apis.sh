#!/usr/bin/env bash

# ============================================================================
# AI APIs Environment Setup Script for macOS (Intel)
# Customized for Steven's API Collection
# ============================================================================
# This script will:
# 1. Install Miniforge (if not already installed)
# 2. Create a comprehensive conda environment with ALL your APIs
# 3. Use your existing ~/.env.d/ system
# 4. Set up helper scripts and examples
# ============================================================================

set -e  # Exit on error

echo "🚀 AI APIs Environment Setup - Custom Configuration"
echo "====================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "${CYAN}${1}${NC}"
}

# ============================================================================
# Step 1: Check and Install Miniforge
# ============================================================================

print_header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_header "  STEP 1: Checking Miniforge Installation"
print_header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if command -v mamba &> /dev/null; then
    print_success "Mamba is already installed!"
    mamba --version
elif command -v conda &> /dev/null; then
    print_warning "Conda found, but Mamba is not installed. Installing Mamba..."
    conda install -n base -c conda-forge mamba -y
else
    print_info "Miniforge not found. Installing Miniforge..."
    
    # Download Miniforge for macOS Intel
    MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh"
    MINIFORGE_INSTALLER="$HOME/miniforge_installer.sh"
    
    print_info "Downloading Miniforge..."
    curl -L -o "$MINIFORGE_INSTALLER" "$MINIFORGE_URL"
    
    print_info "Running Miniforge installer..."
    bash "$MINIFORGE_INSTALLER" -b -p "$HOME/miniforge3"
    
    # Initialize conda
    "$HOME/miniforge3/bin/conda" init bash
    "$HOME/miniforge3/bin/conda" init zsh
    
    # Clean up
    rm "$MINIFORGE_INSTALLER"
    
    print_success "Miniforge installed successfully!"
    print_warning "Please restart your terminal or run: source ~/.zshrc (or ~/.bash_profile)"
    
    # Source the conda setup for this script
    source "$HOME/miniforge3/etc/profile.d/conda.sh"
fi

# ============================================================================
# Step 2: Use Existing ~/.env.d/ System
# ============================================================================

print_header ""
print_header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_header "  STEP 2: Setting Up API Keys"
print_header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if user's ~/.env.d/ system exists
if [ -f "$HOME/.env.d/loader.sh" ]; then
    print_success "Found your existing ~/.env.d/ system"
    
    # Load the environment to check for API keys
    source "$HOME/.env.d/loader.sh" 2>/dev/null || true
    
    # Count configured API keys
    api_keys=$(env | grep -E "_API_KEY=|_TOKEN=" | wc -l | tr -d ' ')
    print_info "Detected $api_keys API keys in ~/.env.d/ system"
    echo ""
    print_info "Your ~/.env.d/ system will be used directly - no copying needed!"
else
    print_warning "No ~/.env.d/ system found"
    print_info "You can add your API keys to ~/.env.d/ files later"
fi

# ============================================================================
# Step 3: Create AI APIs Environment
# ============================================================================

print_header ""
print_header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_header "  STEP 3: Creating AI APIs Environment"
print_header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if environment.yml exists
ENV_FILE="$HOME/ai-apis-environment.yml"
if [ ! -f "$ENV_FILE" ]; then
    print_error "Environment file not found at: $ENV_FILE"
    print_info "Please ensure ai-apis-environment.yml is in your home directory."
    exit 1
fi

# Remove existing environment if it exists
if mamba env list 2>/dev/null | grep -q "ai-apis"; then
    print_warning "Environment 'ai-apis' already exists. Removing..."
    mamba env remove -n ai-apis -y
fi

print_info "Creating environment from ai-apis-environment.yml..."
print_warning "This may take 10-15 minutes (installing 100+ packages)..."
echo ""

mamba env create -f "$ENV_FILE"

print_success "Environment created successfully!"

# ============================================================================
# Step 4: Create activation helper script
# ============================================================================

print_header ""
print_header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_header "  STEP 4: Creating Helper Scripts"
print_header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cat > "$HOME/.activate-ai-apis.sh" << 'EOF'
#!/bin/bash
# Helper script to activate AI APIs environment and load API keys

# Activate the conda environment
eval "$(conda shell.bash hook)"
conda activate ai-apis

# Load API keys from ~/.env.d/ system
if [ -f "$HOME/.env.d/loader.sh" ]; then
    source "$HOME/.env.d/loader.sh" 2>/dev/null || true
    echo "✅ AI APIs environment activated and API keys loaded from ~/.env.d/!"
    echo ""
    
    # Count active keys
    active_keys=$(env | grep -E "_API_KEY=|_TOKEN=" | wc -l | tr -d ' ')
    echo "📊 Active API Keys: $active_keys"
else
    echo "⚠️  AI APIs environment activated, but no ~/.env.d/ system found."
    echo "   Add your API keys to ~/.env.d/ files"
fi

echo ""
echo "🎯 Available API Categories:"
echo "   📝 Text/LLM: OpenAI, Anthropic, Groq, DeepSeek, Grok"
echo "   🖼️  Vision: Stability, Replicate, Runway, Leonardo"
echo "   🎵 Audio: ElevenLabs, AssemblyAI, Deepgram, Suno"
echo "   🤖 Agents: LangChain, LlamaIndex, CrewAI, AutoGen"
echo "   🗄️  Vector DBs: Pinecone, Chroma, Qdrant, Supabase"
echo "   🔍 Search: SerpAPI, NewsAPI"
echo ""
echo "💡 Quick test: python ~/test-apis.py"
EOF

chmod +x "$HOME/.activate-ai-apis.sh"
print_success "Created activation script at: ~/.activate-ai-apis.sh"

# ============================================================================
# Step 5: Create comprehensive test script
# ============================================================================

print_info "Creating API test script..."

cat > "$HOME/test-apis.py" << 'PYEOF'
"""
Comprehensive API Test Script
Tests all your configured APIs
"""

import os
import sys
from typing import Dict, List

def print_header(text: str):
    print(f"\n{'='*70}")
    print(f"  {text}")
    print(f"{'='*70}\n")

def check_api_key(name: str, env_var: str) -> bool:
    """Check if API key is set and valid"""
    key = os.getenv(env_var)
    if key and not key.startswith("your_") and len(key) > 10:
        print(f"✅ {name:30} - Key found ({len(key)} chars)")
        return True
    else:
        print(f"⚠️  {name:30} - Not configured")
        return False

def test_openai():
    """Test OpenAI API"""
    try:
        from openai import OpenAI
        client = OpenAI()
        response = client.chat.completions.create(
            model=os.getenv("OPENAI_MODEL", "gpt-4"),
            messages=[{"role": "user", "content": "Say 'Hello from OpenAI!'"}],
            max_tokens=20
        )
        print(f"   Response: {response.choices[0].message.content}")
        return True
    except Exception as e:
        print(f"   Error: {e}")
        return False

def test_anthropic():
    """Test Anthropic API"""
    try:
        from anthropic import Anthropic
        client = Anthropic()
        message = client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=20,
            messages=[{"role": "user", "content": "Say 'Hello from Claude!'"}]
        )
        print(f"   Response: {message.content[0].text}")
        return True
    except Exception as e:
        print(f"   Error: {e}")
        return False

def test_groq():
    """Test Groq API"""
    try:
        from groq import Groq
        client = Groq()
        response = client.chat.completions.create(
            model="llama3-8b-8192",
            messages=[{"role": "user", "content": "Say 'Hello from Groq!'"}],
            max_tokens=20
        )
        print(f"   Response: {response.choices[0].message.content}")
        return True
    except Exception as e:
        print(f"   Error: {e}")
        return False

def test_assemblyai():
    """Test AssemblyAI API"""
    try:
        import assemblyai as aai
        aai.settings.api_key = os.getenv("ASSEMBLYAI_API_KEY")
        print(f"   SDK initialized successfully")
        return True
    except Exception as e:
        print(f"   Error: {e}")
        return False

def test_deepgram():
    """Test Deepgram API"""
    try:
        from deepgram import DeepgramClient
        client = DeepgramClient(os.getenv("DEEPGRAM_API_KEY"))
        print(f"   Client initialized successfully")
        return True
    except Exception as e:
        print(f"   Error: {e}")
        return False

# ============================================================================
# Main Test Suite
# ============================================================================

print_header("🧪 API Configuration Test")

print("Checking API Keys...\n")

# Text/LLM APIs
print("📝 TEXT/LLM APIs:")
llm_keys = {
    "OpenAI": "OPENAI_API_KEY",
    "Anthropic (Claude)": "ANTHROPIC_API_KEY",
    "Groq": "GROQ_API_KEY",
    "Grok (X.AI)": "GROK_API_KEY",
    "DeepSeek": "DEEPSEEK_API_KEY",
    "Cohere": "COHERE_API_KEY",
    "Fireworks": "FIREWORKS_API_KEY",
}

configured_llm = []
for name, var in llm_keys.items():
    if check_api_key(name, var):
        configured_llm.append(name)

# Vision/Image APIs
print("\n🖼️  VISION/IMAGE APIs:")
vision_keys = {
    "Stability AI": "STABILITY_API_KEY",
    "Replicate": "REPLICATE_API_TOKEN",
    "Runway": "RUNWAY_API_KEY",
    "Leonardo": "LEONARDO_API_KEY",
}

configured_vision = []
for name, var in vision_keys.items():
    if check_api_key(name, var):
        configured_vision.append(name)

# Audio/Music APIs
print("\n🎵 AUDIO/MUSIC APIs:")
audio_keys = {
    "ElevenLabs": "ELEVENLABS_API_KEY",
    "AssemblyAI": "ASSEMBLYAI_API_KEY",
    "Deepgram": "DEEPGRAM_API_KEY",
    "Suno": "SUNO_API_KEY",
}

configured_audio = []
for name, var in audio_keys.items():
    if check_api_key(name, var):
        configured_audio.append(name)

# Vector/Storage APIs
print("\n🗄️  VECTOR/STORAGE APIs:")
vector_keys = {
    "Pinecone": "PINECONE_API_KEY",
    "Qdrant": "QDRANT_API_KEY",
    "Supabase": "SUPABASE_KEY",
    "ChromaDB": "CHROMADB_API_KEY",
}

configured_vector = []
for name, var in vector_keys.items():
    if check_api_key(name, var):
        configured_vector.append(name)

# Search/Analytics APIs
print("\n🔍 SEARCH/ANALYTICS APIs:")
search_keys = {
    "SerpAPI": "SERPAPI_KEY",
    "NewsAPI": "NEWSAPI_KEY",
}

configured_search = []
for name, var in search_keys.items():
    if check_api_key(name, var):
        configured_search.append(name)

# ============================================================================
# Live API Tests (for configured APIs)
# ============================================================================

print_header("🚀 Live API Tests")

if "OpenAI" in configured_llm:
    print("\n🧪 Testing OpenAI...")
    test_openai()

if "Anthropic (Claude)" in configured_llm:
    print("\n🧪 Testing Anthropic (Claude)...")
    test_anthropic()

if "Groq" in configured_llm:
    print("\n🧪 Testing Groq...")
    test_groq()

if "AssemblyAI" in configured_audio:
    print("\n🧪 Testing AssemblyAI...")
    test_assemblyai()

if "Deepgram" in configured_audio:
    print("\n🧪 Testing Deepgram...")
    test_deepgram()

# ============================================================================
# Summary
# ============================================================================

print_header("📊 Summary")

total_configured = (
    len(configured_llm) + 
    len(configured_vision) + 
    len(configured_audio) + 
    len(configured_vector) + 
    len(configured_search)
)

print(f"Total Configured APIs: {total_configured}")
print(f"  📝 LLM APIs: {len(configured_llm)}")
print(f"  🖼️  Vision APIs: {len(configured_vision)}")
print(f"  🎵 Audio APIs: {len(configured_audio)}")
print(f"  🗄️  Vector DBs: {len(configured_vector)}")
print(f"  🔍 Search APIs: {len(configured_search)}")

print("\n✅ Setup complete! Start building with your APIs.")
print("\n📚 Documentation:")
print("   - See ~/AI_APIS_REFERENCE.md for code examples")
print("   - See ~/AI_EXAMPLES.py for practical use cases")

PYEOF

print_success "Created test script at: ~/test-apis.py"

# ============================================================================
# Step 6: Create quick examples file
# ============================================================================

print_info "Creating examples file..."

cat > "$HOME/AI_EXAMPLES.py" << 'EXEOF'
"""
Quick Start Examples for Your APIs
Practical examples using your configured APIs
"""

import os

# ============================================================================
# 1. Multi-Model LLM Comparison
# ============================================================================

def compare_llms(prompt: str):
    """Compare responses from OpenAI, Anthropic, and Groq"""
    
    results = {}
    
    # OpenAI
    try:
        from openai import OpenAI
        client = OpenAI()
        response = client.chat.completions.create(
            model="gpt-4",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=100
        )
        results["OpenAI GPT-4"] = response.choices[0].message.content
    except Exception as e:
        results["OpenAI GPT-4"] = f"Error: {e}"
    
    # Anthropic Claude
    try:
        from anthropic import Anthropic
        client = Anthropic()
        message = client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=100,
            messages=[{"role": "user", "content": prompt}]
        )
        results["Claude Sonnet"] = message.content[0].text
    except Exception as e:
        results["Claude Sonnet"] = f"Error: {e}"
    
    # Groq (Fast)
    try:
        from groq import Groq
        client = Groq()
        response = client.chat.completions.create(
            model="llama3-70b-8192",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=100
        )
        results["Groq Llama3"] = response.choices[0].message.content
    except Exception as e:
        results["Groq Llama3"] = f"Error: {e}"
    
    return results

# ============================================================================
# 2. Audio Transcription (AssemblyAI or Deepgram)
# ============================================================================

def transcribe_audio(audio_url: str, provider: str = "assemblyai"):
    """Transcribe audio using AssemblyAI or Deepgram"""
    
    if provider == "assemblyai":
        import assemblyai as aai
        aai.settings.api_key = os.getenv("ASSEMBLYAI_API_KEY")
        
        transcriber = aai.Transcriber()
        transcript = transcriber.transcribe(audio_url)
        
        return transcript.text
    
    elif provider == "deepgram":
        from deepgram import DeepgramClient, PrerecordedOptions
        
        client = DeepgramClient(os.getenv("DEEPGRAM_API_KEY"))
        
        response = client.listen.prerecorded.v("1").transcribe_url(
            {"url": audio_url},
            PrerecordedOptions(model="nova-2", smart_format=True)
        )
        
        return response.results.channels[0].alternatives[0].transcript

# ============================================================================
# 3. RAG with Multiple Vector DBs
# ============================================================================

def rag_with_chroma(documents: list, query: str):
    """RAG using ChromaDB"""
    from langchain_openai import OpenAIEmbeddings, ChatOpenAI
    from langchain_community.vectorstores import Chroma
    from langchain.text_splitter import RecursiveCharacterTextSplitter
    from langchain.chains import RetrievalQA
    
    # Split documents
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000)
    texts = text_splitter.create_documents(documents)
    
    # Create vector store
    embeddings = OpenAIEmbeddings()
    vectorstore = Chroma.from_documents(texts, embeddings)
    
    # Create QA chain
    qa_chain = RetrievalQA.from_chain_type(
        llm=ChatOpenAI(model="gpt-4"),
        retriever=vectorstore.as_retriever()
    )
    
    return qa_chain.run(query)

# ============================================================================
# 4. Image Generation (if Stability or Replicate configured)
# ============================================================================

def generate_image_stability(prompt: str):
    """Generate image with Stability AI"""
    import requests
    
    response = requests.post(
        "https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image",
        headers={
            "Authorization": f"Bearer {os.getenv('STABILITY_API_KEY')}",
            "Content-Type": "application/json",
        },
        json={
            "text_prompts": [{"text": prompt}],
            "cfg_scale": 7,
            "height": 1024,
            "width": 1024,
            "steps": 30,
        },
    )
    
    if response.status_code == 200:
        data = response.json()
        return data["artifacts"][0]["base64"]
    else:
        raise Exception(f"Error: {response.text}")

# ============================================================================
# 5. Multi-Agent System (CrewAI)
# ============================================================================

def create_research_crew(topic: str):
    """Create a multi-agent research crew"""
    from crewai import Agent, Task, Crew, Process
    from langchain_openai import ChatOpenAI
    
    llm = ChatOpenAI(model="gpt-4")
    
    # Define agents
    researcher = Agent(
        role='Senior Researcher',
        goal=f'Research and gather information about {topic}',
        backstory='Expert researcher with years of experience',
        llm=llm
    )
    
    writer = Agent(
        role='Content Writer',
        goal='Write engaging content based on research',
        backstory='Professional writer skilled at making complex topics accessible',
        llm=llm
    )
    
    # Define tasks
    research_task = Task(
        description=f'Research {topic} thoroughly',
        agent=researcher
    )
    
    write_task = Task(
        description='Write a comprehensive article based on the research',
        agent=writer
    )
    
    # Create crew
    crew = Crew(
        agents=[researcher, writer],
        tasks=[research_task, write_task],
        process=Process.sequential
    )
    
    result = crew.kickoff()
    return result

# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("🚀 AI Examples - Ready to use!")
    print("\nAvailable functions:")
    print("  1. compare_llms(prompt) - Compare OpenAI, Claude, Groq")
    print("  2. transcribe_audio(url, provider) - Transcribe audio")
    print("  3. rag_with_chroma(docs, query) - RAG with vector DB")
    print("  4. generate_image_stability(prompt) - Generate images")
    print("  5. create_research_crew(topic) - Multi-agent research")
    print("\nImport and use these functions in your projects!")

EXEOF

print_success "Created examples at: ~/AI_EXAMPLES.py"

# ============================================================================
# Final Instructions
# ============================================================================

echo ""
print_header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_header "  🎉 Installation Complete!"
print_header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

print_success "Your AI development environment is ready!"
echo ""

print_info "📁 Files Created:"
echo "   ~/.env.d/                   - Your organized API keys system"
echo "   ~/.activate-ai-apis.sh      - Quick activation script"
echo "   ~/test-apis.py              - API configuration test"
echo "   ~/AI_EXAMPLES.py            - Practical examples"
echo "   ~/AI_APIS_REFERENCE.md      - Complete API reference"
echo ""

print_info "🚀 Next Steps:"
echo ""
echo "1. Activate the environment:"
echo "   ${GREEN}source ~/.activate-ai-apis.sh${NC}"
echo "   ${CYAN}# Or add alias: alias ai='source ~/.activate-ai-apis.sh'${NC}"
echo ""
echo "2. Test your APIs:"
echo "   ${GREEN}python ~/test-apis.py${NC}"
echo ""
echo "3. Try the examples:"
echo "   ${GREEN}python -c 'from AI_EXAMPLES import compare_llms; print(compare_llms(\"Explain AI\"))'${NC}"
echo ""
echo "4. Start building:"
echo "   ${GREEN}jupyter lab${NC}"
echo "   ${CYAN}# Or use any Python script with your APIs${NC}"
echo ""

print_info "💡 Pro Tips:"
echo "   • All your existing API keys are already loaded"
echo "   • Environment includes 100+ packages for AI development"
echo "   • Use LangChain for multi-model orchestration"
echo "   • Check AI_APIS_REFERENCE.md for detailed examples"
echo ""

print_info "📚 Documentation Locations:"
echo "   ~/AI_APIS_REFERENCE.md  - Complete API reference"
echo "   ~/AI_EXAMPLES.py        - Practical code examples"
echo ""

print_success "Happy coding! 🎉"
echo ""
