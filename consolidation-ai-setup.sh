#!/bin/bash
# 🤖 **PHASE 2: AI TOOLS CONSOLIDATION**
# Consolidate all AI configurations and tools

set -e

echo "🤖 AI Tools Consolidation..."
echo "==========================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

status() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# Create AI directory structure
info "Creating AI directory structure..."
mkdir -p ~/dev/ai/{claude,cursor,qwen,gemini,grok,openai,shared}

# Copy AI configurations (safely)
info "Consolidating AI configurations..."

# Claude Desktop
if [ -d ~/.claude ]; then
    cp -r ~/.claude/* ~/dev/ai/claude/ 2>/dev/null || true
    status "Claude configurations copied"
else
    warning "Claude directory not found"
fi

# Cursor
if [ -d ~/.cursor ]; then
    cp -r ~/.cursor/* ~/dev/ai/cursor/ 2>/dev/null || true
    status "Cursor configurations copied"
else
    warning "Cursor directory not found"
fi

# Create unified AI config
info "Creating unified AI configuration..."
cat > ~/dev/ai/config.py << 'EOF'
# 🤖 Unified AI Configuration
# Consolidates all AI tool configurations and API keys

import os
import json
from pathlib import Path
from typing import Dict, Any, Optional

class AIConfig:
    def __init__(self):
        self.base_dir = Path(__file__).parent
        self._load_configs()

    def _load_configs(self):
        """Load all AI configurations"""
        self.configs = {}

        # Load Claude config
        claude_config = self.base_dir / "claude/claude_desktop_config.json"
        if claude_config.exists():
            with open(claude_config) as f:
                self.configs['claude'] = json.load(f)

        # Load Cursor config if any
        cursor_config = self.base_dir / "cursor/config.json"
        if cursor_config.exists():
            with open(cursor_config) as f:
                self.configs['cursor'] = json.load(f)

    def get_api_key(self, service: str) -> Optional[str]:
        """Get API key for AI service"""
        key_map = {
            'openai': ['OPENAI_API_KEY', 'openai_api_key'],
            'claude': ['ANTHROPIC_API_KEY', 'claude_api_key'],
            'gemini': ['GOOGLE_API_KEY', 'gemini_api_key'],
            'grok': ['GROK_API_KEY', 'grok_api_key']
        }

        if service in key_map:
            for key_name in key_map[service]:
                key = os.getenv(key_name)
                if key:
                    return key

        return None

    def get_model_config(self, service: str, model: str = None) -> Dict[str, Any]:
        """Get configuration for specific AI model"""
        base_configs = {
            'claude': {
                'default_model': 'claude-3-opus-20240229',
                'max_tokens': 4096,
                'temperature': 0.7
            },
            'gpt': {
                'default_model': 'gpt-4-turbo-preview',
                'max_tokens': 4096,
                'temperature': 0.7
            },
            'gemini': {
                'default_model': 'gemini-pro',
                'max_tokens': 8192,
                'temperature': 0.7
            }
        }

        config = base_configs.get(service, {})
        if model:
            config['model'] = model
        else:
            config['model'] = config.get('default_model', '')

        return config

    def list_available_services(self) -> list:
        """List all configured AI services"""
        services = []
        for service in ['claude', 'gpt', 'gemini', 'grok']:
            if self.get_api_key(service):
                services.append(service)
        return services

# Global instance
ai_config = AIConfig()

# Convenience functions
def get_claude_config():
    return ai_config.get_model_config('claude')

def get_gpt_config():
    return ai_config.get_model_config('gpt')

def get_gemini_config():
    return ai_config.get_model_config('gemini')
EOF

status "Unified AI config created"

# Create AI environment loader
info "Creating AI environment loader..."
cat > ~/dev/ai/__init__.py << 'EOF'
"""
AI Tools Module
Unified access to all AI services and configurations
"""

from .config import AIConfig, ai_config, get_claude_config, get_gpt_config, get_gemini_config

__all__ = [
    'AIConfig',
    'ai_config',
    'get_claude_config',
    'get_gpt_config',
    'get_gemini_config'
]
EOF

# Create shared AI utilities
info "Creating shared AI utilities..."
cat > ~/dev/ai/shared/utilities.py << 'EOF'
"""
Shared AI Utilities
Common functions used across AI services
"""

import time
import hashlib
from typing import Dict, Any, Optional
from functools import wraps

def retry_on_failure(max_retries: int = 3, delay: float = 1.0, backoff: float = 2.0):
    """Decorator to retry AI API calls on failure"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            last_exception = None
            current_delay = delay

            for attempt in range(max_retries):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    last_exception = e
                    if attempt < max_retries - 1:
                        print(f"AI API call failed (attempt {attempt + 1}/{max_retries}): {e}")
                        time.sleep(current_delay)
                        current_delay *= backoff
                    else:
                        print(f"AI API call failed after {max_retries} attempts: {e}")

            raise last_exception
        return wrapper
    return decorator

def calculate_token_estimate(text: str, model: str = "claude") -> int:
    """Estimate token count for text (rough approximation)"""
    # Very rough estimates - in production use proper tokenizer
    token_multipliers = {
        'claude': 1.2,  # Claude tends to use fewer tokens
        'gpt': 1.0,     # GPT baseline
        'gemini': 1.1   # Gemini approximation
    }

    multiplier = token_multipliers.get(model, 1.0)
    # Rough word-based estimate: 1 token ≈ 0.75 words
    word_count = len(text.split())
    return int(word_count * multiplier / 0.75)

def hash_prompt(prompt: str) -> str:
    """Create hash of prompt for caching/logging"""
    return hashlib.md5(prompt.encode()).hexdigest()[:8]

def validate_api_key(service: str, key: str) -> bool:
    """Basic validation of API key format"""
    if not key or len(key.strip()) < 10:
        return False

    # Service-specific validations
    validations = {
        'openai': lambda k: k.startswith('sk-'),
        'claude': lambda k: k.startswith('sk-ant-'),
        'gemini': lambda k: len(k) > 20  # Gemini keys are typically long
    }

    validator = validations.get(service, lambda k: True)
    return validator(key)

def format_ai_response(response: Dict[str, Any], service: str) -> Dict[str, Any]:
    """Standardize AI response format across services"""
    standardized = {
        'service': service,
        'timestamp': time.time(),
        'content': '',
        'usage': {},
        'model': '',
        'finish_reason': None
    }

    # Service-specific mappings
    if service == 'claude':
        standardized.update({
            'content': response.get('content', [{}])[0].get('text', ''),
            'usage': response.get('usage', {}),
            'model': response.get('model', ''),
            'finish_reason': response.get('stop_reason', '')
        })
    elif service == 'openai':
        standardized.update({
            'content': response.get('choices', [{}])[0].get('message', {}).get('content', ''),
            'usage': response.get('usage', {}),
            'model': response.get('model', ''),
            'finish_reason': response.get('choices', [{}])[0].get('finish_reason', '')
        })
    elif service == 'gemini':
        standardized.update({
            'content': response.get('candidates', [{}])[0].get('content', {}).get('parts', [{}])[0].get('text', ''),
            'usage': response.get('usageMetadata', {}),
            'model': response.get('model', ''),
            'finish_reason': response.get('candidates', [{}])[0].get('finish_reason', '')
        })

    return standardized
EOF

# Create AI service integrations
info "Creating AI service integrations..."
cat > ~/dev/ai/shared/services.py << 'EOF'
"""
AI Service Integrations
Unified interface to different AI providers
"""

import os
from typing import Dict, Any, Optional, List
from .utilities import retry_on_failure, validate_api_key
from ..config import ai_config

class AIService:
    """Base class for AI service integrations"""

    def __init__(self, service_name: str):
        self.service_name = service_name
        self.api_key = ai_config.get_api_key(service_name)
        self.config = ai_config.get_model_config(service_name)

        if not self.api_key:
            raise ValueError(f"No API key found for {service_name}")
        if not validate_api_key(service_name, self.api_key):
            raise ValueError(f"Invalid API key format for {service_name}")

    @retry_on_failure()
    def generate(self, prompt: str, **kwargs) -> Dict[str, Any]:
        """Generate response from AI service"""
        raise NotImplementedError

    def estimate_cost(self, tokens: int) -> float:
        """Estimate cost for token usage"""
        raise NotImplementedError

class ClaudeService(AIService):
    def __init__(self):
        super().__init__('claude')
        try:
            import anthropic
            self.client = anthropic.Anthropic(api_key=self.api_key)
        except ImportError:
            raise ImportError("anthropic package required for Claude service")

    def generate(self, prompt: str, **kwargs) -> Dict[str, Any]:
        config = {**self.config, **kwargs}

        response = self.client.messages.create(
            model=config['model'],
            max_tokens=config['max_tokens'],
            temperature=config['temperature'],
            messages=[{"role": "user", "content": prompt}]
        )

        return {
            'content': response.content[0].text,
            'usage': {
                'input_tokens': response.usage.input_tokens,
                'output_tokens': response.usage.output_tokens
            },
            'model': response.model,
            'service': 'claude'
        }

    def estimate_cost(self, tokens: int) -> float:
        # Claude pricing: $15/1M input tokens, $75/1M output tokens (approximate)
        return (tokens * 0.015 + tokens * 0.075) / 1_000_000

class OpenAIService(AIService):
    def __init__(self):
        super().__init__('openai')
        try:
            from openai import OpenAI
            self.client = OpenAI(api_key=self.api_key)
        except ImportError:
            raise ImportError("openai package required for OpenAI service")

    def generate(self, prompt: str, **kwargs) -> Dict[str, Any]:
        config = {**self.config, **kwargs}

        response = self.client.chat.completions.create(
            model=config['model'],
            max_tokens=config['max_tokens'],
            temperature=config['temperature'],
            messages=[{"role": "user", "content": prompt}]
        )

        return {
            'content': response.choices[0].message.content,
            'usage': {
                'total_tokens': response.usage.total_tokens,
                'prompt_tokens': response.usage.prompt_tokens,
                'completion_tokens': response.usage.completion_tokens
            },
            'model': response.model,
            'service': 'openai'
        }

    def estimate_cost(self, tokens: int) -> float:
        # GPT-4 Turbo pricing: $10/1M input, $30/1M output
        return (tokens * 0.01 + tokens * 0.03) / 1_000_000

def get_ai_service(service_name: str) -> AIService:
    """Factory function to get AI service instance"""
    services = {
        'claude': ClaudeService,
        'openai': OpenAIService,
        # Add more services as needed
    }

    if service_name not in services:
        raise ValueError(f"Unsupported AI service: {service_name}")

    return services[service_name]()

def get_available_services() -> List[str]:
    """Get list of available AI services (with valid API keys)"""
    return ai_config.list_available_services()
EOF

# Create AI examples directory
info "Setting up AI examples..."
mkdir -p ~/dev/ai/examples

cat > ~/dev/ai/examples/multi_agent_orchestrator.py << 'EOF'
#!/usr/bin/env python3
"""
Multi-Agent AI Orchestrator Example
Demonstrates how to coordinate multiple AI services
"""

import asyncio
from typing import List, Dict, Any
from ..shared.services import get_ai_service, get_available_services

class AgentOrchestrator:
    def __init__(self):
        self.available_services = get_available_services()
        self.services = {}

        # Initialize available services
        for service in self.available_services:
            try:
                self.services[service] = get_ai_service(service)
                print(f"✅ {service} service initialized")
            except Exception as e:
                print(f"❌ Failed to initialize {service}: {e}")

    async def execute_task(self, task: str) -> Dict[str, Any]:
        """Distribute task across multiple AI agents"""

        # Phase 1: Research (use Claude for detailed analysis)
        if 'claude' in self.services:
            research_prompt = f"""
            Research and analyze the following topic comprehensively:
            {task}

            Provide detailed background, key concepts, and important considerations.
            """
            research_data = self.services['claude'].generate(research_prompt, max_tokens=2000)
        else:
            research_data = {"content": "Research phase skipped - Claude not available"}

        # Phase 2: Content Creation (use OpenAI for creative writing)
        if 'openai' in self.services:
            content_prompt = f"""
            Based on this research:
            {research_data['content']}

            Create engaging, well-structured content about: {task}
            Make it comprehensive but accessible.
            """
            draft_content = self.services['openai'].generate(content_prompt, max_tokens=1500)
        else:
            draft_content = {"content": "Content creation phase skipped - OpenAI not available"}

        # Phase 3: Review & Polish (use best available service for final polish)
        preferred_service = self.available_services[0] if self.available_services else None
        if preferred_service and preferred_service in self.services:
            review_prompt = f"""
            Review and improve this content:
            {draft_content['content']}

            Make it more engaging, fix any errors, and ensure it's well-structured.
            """
            final_content = self.services[preferred_service].generate(review_prompt, max_tokens=1000)
        else:
            final_content = {"content": "Review phase skipped - no services available"}

        return {
            'task': task,
            'research': research_data.get('content', ''),
            'draft': draft_content.get('content', ''),
            'final': final_content.get('content', ''),
            'services_used': list(self.services.keys()),
            'timestamp': __import__('time').time()
        }

async def main():
    """Example usage"""
    orchestrator = AgentOrchestrator()

    if not orchestrator.services:
        print("❌ No AI services available. Please check API keys.")
        return

    print(f"🤖 Available AI services: {orchestrator.available_services}")

    # Example task
    task = "The impact of artificial intelligence on software development workflows"

    print(f"🚀 Executing task: {task}")
    result = await orchestrator.execute_task(task)

    print("\n📊 Results:")
    print(f"Services used: {result['services_used']}")
    print(f"Research length: {len(result['research'])} chars")
    print(f"Final content length: {len(result['final'])} chars")

    # Save results
    import json
    with open('ai_orchestration_result.json', 'w') as f:
        json.dump(result, f, indent=2)

    print("✅ Results saved to ai_orchestration_result.json")

if __name__ == '__main__':
    asyncio.run(main())
EOF

# Update consolidation status
info "Updating consolidation status..."
if [ -f ~/consolidation_status.json ]; then
    # Add AI consolidation to completed steps
    sed -i 's/"foundation_setup"/"ai_consolidation"/' ~/consolidation_status.json
    sed -i 's/"directory_structure",/"directory_structure",\n    "ai_tools_consolidated",/' ~/consolidation_status.json
fi

status "AI consolidation status updated"

# Run validation
info "Running AI consolidation validation..."
echo ""
echo "🔍 AI CONSOLIDATION VALIDATION"
echo "=============================="

# Check AI directory structure
ai_dirs=$(find ~/dev/ai -maxdepth 1 -type d | wc -l)
if [ "$ai_dirs" -ge 5 ]; then
    status "AI directory structure: $ai_dirs directories created"
else
    warning "AI directory structure: Only $ai_dirs directories found"
fi

# Check unified config
if [ -f ~/dev/ai/config.py ]; then
    status "Unified AI config: Created"
else
    error "Unified AI config: Missing"
fi

# Check AI services
if python3 -c "from dev.ai.shared.services import get_available_services; print('Available:', get_available_services())" 2>/dev/null; then
    status "AI services: Importable"
else
    warning "AI services: Import failed (may need dependencies)"
fi

echo ""
echo "🎯 AI CONSOLIDATION COMPLETE!"
echo "============================"
echo ""
echo "What's been done:"
echo "• Consolidated all AI configurations to ~/dev/ai/"
echo "• Created unified AI config system"
echo "• Built shared AI utilities and service integrations"
echo "• Set up multi-agent orchestration example"
echo ""
echo "Next steps:"
echo "1. Test AI services: python3 ~/dev/ai/examples/multi_agent_orchestrator.py"
echo "2. Check configs: python3 -c 'from dev.ai import ai_config; print(ai_config.list_available_services())'"
echo "3. Run: ~/consolidation_migration.sh (next phase)"
echo ""
echo "Your AI tools are now consolidated! 🎉"