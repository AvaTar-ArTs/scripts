#!/usr/bin/env python3
"""
Advanced Meta CSV Generator for ~/scripts directory
This script analyzes all scripts in the ~/scripts directory and generates
a comprehensive meta CSV with detailed information about each script.
"""

import os
import csv
import hashlib
import json
from pathlib import Path
from datetime import datetime
import re
import subprocess
import sys

def get_file_hash(filepath):
    """Calculate MD5 hash of a file"""
    hash_md5 = hashlib.md5()
    try:
        with open(filepath, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()
    except:
        return ""

def get_file_size(filepath):
    """Get file size in bytes"""
    try:
        return os.path.getsize(filepath)
    except:
        return 0

def get_modification_time(filepath):
    """Get file modification time"""
    try:
        mod_time = os.path.getmtime(filepath)
        return datetime.fromtimestamp(mod_time).isoformat()
    except:
        return ""

def detect_shebang(filepath):
    """Detect the shebang of a script file"""
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            first_line = f.readline().strip()
            if first_line.startswith('#!'):
                return first_line
    except:
        pass
    return ""

def detect_language(filepath):
    """Detect the programming language based on file extension and shebang"""
    ext = Path(filepath).suffix.lower()
    shebang = detect_shebang(filepath)
    
    if '.py' in str(filepath):
        return 'Python'
    elif '.sh' in str(filepath) or 'bash' in shebang or 'sh' in shebang or 'zsh' in shebang:
        return 'Shell'
    elif '.js' in str(filepath):
        return 'JavaScript'
    elif '.ts' in str(filepath):
        return 'TypeScript'
    elif '.go' in str(filepath):
        return 'Go'
    elif '.rb' in str(filepath):
        return 'Ruby'
    elif '.pl' in str(filepath):
        return 'Perl'
    elif '.php' in str(filepath):
        return 'PHP'
    elif '.lua' in str(filepath):
        return 'Lua'
    elif '.sql' in str(filepath):
        return 'SQL'
    else:
        return 'Unknown'

def extract_imports(filepath):
    """Extract import/include statements from the script"""
    imports = []
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            
        # Look for import statements based on language
        lang = detect_language(filepath)
        
        if lang == 'Python':
            imports = re.findall(r'^\s*import\s+([a-zA-Z0-9_]+)', content, re.MULTILINE)
            imports += re.findall(r'^\s*from\s+([a-zA-Z0-9_.]+)\s+import', content, re.MULTILINE)
        elif lang == 'Shell':
            imports = re.findall(r'^\s*source\s+[\'"]?([^\'"\s]+)[\'"]?', content, re.MULTILINE)
            imports += re.findall(r'^\s*\. \s*[\'"]?([^\'"\s]+)[\'"]?', content, re.MULTILINE)
        elif lang == 'JavaScript':
            imports = re.findall(r'^\s*import\s+.+\s+from\s+[\'"](.+)[\'"]', content, re.MULTILINE)
            imports += re.findall(r'^\s*require\s*\([\'"](.+)[\'"]\)', content, re.MULTILINE)
    
        # Remove duplicates and return as comma-separated string
        imports = list(set(imports))
    except:
        pass
    
    return ','.join(imports) if imports else ""

def extract_api_keys(filepath):
    """Extract potential API key references from the script"""
    apis = []
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        # Look for common API patterns
        patterns = [
            r'[A-Z_]*API[_-]?KEY',
            r'[A-Z_]*TOKEN',
            r'[A-Z_]*SECRET',
            r'OPENAI',
            r'GROQ',
            r'XAI',
            r'DEEPK',
            r'STABLE',
            r'REPLICATE',
            r'ELEVEN',
            r'SUNO',
            r'ASSEMBLY',
            r'DEEPGRAM',
            r'PINECONE',
            r'SERP',
            r'NEWSAPI',
            r'COHERE',
            r'FIREWORKS',
            r'RUNWAY',
            r'QDRANT',
            r'CHROMA',
            r'ZEP',
            r'OPENROUTER',
            r'LANGSMITH',
            r'TWILIO',
            r'ZAPIER',
            r'MAKE',
            r'NOTION',
            r'SLITE',
            r'MOONVALLEY',
            r'ARCGIS',
            r'SUPERNORMAL',
            r'DESCRIBE',
            r'SONIX',
            r'REVAI',
            r'SPEECHMATICS',
            r'AZURE',
            r'OLLAMA',
            r'GROK',
            r'CLAUDE',
            r'ANTHROPIC',
            r'GOOGLE',
            r'GOOGLE_AI',
            r'MISTRAL',
            r'TOGETHER',
            r'PERPLEXITY',
            r'LLAMA',
            r'VECTARA',
            r'PPLX',
            r'VOYAGE',
            r'JINAAI',
            r'NUCLIA',
            r'UPSTAGE',
            r'AWQ',
            r'AUTOAWQ',
            r'GPT4ALL',
            r'HUGGINGFACE',
            r'TEI',
            r'TEXT-EMBEDDING-INFERENCE',
            r'GPTQ',
            r'AUTOGPTQ',
            r'EXLLAMA',
            r'EXLLAMAV2',
            r'GPTQ_FOR_LLAMAS',
            r'SGLANG',
            r'LIGHTLLM',
            r'INFLLM',
            r'FLEXLLM',
            r'ORCA',
            r'MINIGPT',
            r'PHOENIX',
            r'VICUNA',
            r'LLAVA',
            r'GRAD-SUM',
            r'FALCON',
            r'CODELLAMA',
            r'LLAMA_GUARD',
            r'GEMMA',
            r'CHAMELEON',
            r'IDEFICS',
            r'BLIP',
            r'WHISPER',
            r'IMAGE_GEN',
            r'TTS',
            r'STABILITY',
            r'DALLE',
            r'MIDJOURNEY',
            r'LEONARDO',
            r'PROMPT_API',
            r'OPENROUTER',
            r'GROQ_API',
            r'GROQ_API_KEY'
        ]
        
        for pattern in patterns:
            matches = re.findall(pattern, content, re.IGNORECASE)
            apis.extend(matches)
        
        # Remove duplicates and return as comma-separated string
        apis = list(set([api.upper() for api in apis]))
    except:
        pass
    
    return ','.join(apis) if apis else ""

def estimate_complexity(filepath):
    """Estimate script complexity based on file content"""
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        lines = content.count('\n') + 1
        functions = len(re.findall(r'(def |function |^.*\(\) {$|^.*\(\) \{$)', content, re.MULTILINE))
        conditionals = len(re.findall(r'\b(if|elif|else|case|switch)\b', content, re.IGNORECASE))
        loops = len(re.findall(r'\b(for|while|foreach|until)\b', content, re.IGNORECASE))
        
        # Calculate complexity score
        complexity_score = (lines * 0.1) + (functions * 0.5) + (conditionals * 0.3) + (loops * 0.3)
        
        if complexity_score < 5:
            return 'low'
        elif complexity_score < 15:
            return 'medium'
        else:
            return 'high'
    except:
        return 'unknown'

def categorize_script(filepath):
    """Categorize the script based on its name and content"""
    name = Path(filepath).name.lower()
    content = ""
    
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read().lower()
    except:
        pass
    
    # Define categories and keywords
    categories = {
        'AI/ML Tools': ['ai', 'ml', 'machine learning', 'model', 'train', 'predict', 'torch', 'tensorflow', 'sklearn', 'openai', 'gpt', 'chatgpt', 'claude'],
        'System Maintenance': ['cleanup', 'maintenance', 'optimize', 'system', 'performance', 'upgrade', 'update', 'repair', 'fix', 'diagnose'],
        'File Management': ['file', 'rename', 'move', 'copy', 'organize', 'sort', 'duplicate', 'dedupe', 'merge', 'split', 'backup', 'restore'],
        'Media Processing': ['image', 'video', 'audio', 'png', 'jpg', 'mp4', 'mp3', 'wav', 'convert', 'resize', 'compress', 'optimize'],
        'Development Tools': ['git', 'build', 'compile', 'test', 'debug', 'lint', 'format', 'install', 'setup', 'deploy', 'dev', 'development'],
        'API Integration': ['api', 'key', 'token', 'auth', 'authenticate', 'request', 'response', 'endpoint', 'webhook', 'oauth'],
        'Automation': ['auto', 'automate', 'cron', 'schedule', 'batch', 'script', 'run', 'execute', 'orchestrate', 'workflow'],
        'Monitoring': ['monitor', 'log', 'status', 'check', 'health', 'alert', 'report', 'stats', 'metrics', 'track'],
        'Security': ['security', 'encrypt', 'decrypt', 'password', 'hash', 'ssl', 'cert', 'firewall', 'scan', 'secure'],
        'Database': ['database', 'db', 'sql', 'query', 'mysql', 'postgres', 'sqlite', 'mongo', 'redis', 'couch'],
        'Networking': ['network', 'http', 'https', 'url', 'download', 'upload', 'sync', 'transfer', 'ping', 'ssh', 'ftp'],
        'Environment Setup': ['env', 'environment', 'config', 'configuration', 'setup', 'install', 'dependencies', 'packages', 'virtual'],
        'Data Analysis': ['data', 'analyze', 'analysis', 'csv', 'json', 'excel', 'pandas', 'numpy', 'stats', 'plot', 'graph'],
        'Text Processing': ['text', 'string', 'regex', 'parse', 'extract', 'replace', 'search', 'find', 'grep', 'sed', 'awk'],
        'Utilities': ['util', 'utility', 'helper', 'tool', 'common', 'shared', 'general', 'basic', 'simple']
    }
    
    # Check content first, then filename
    for category, keywords in categories.items():
        for keyword in keywords:
            if keyword in content or keyword in name:
                return category
    
    # Default category if no match found
    return 'General/Other'

def analyze_script(filepath):
    """Analyze a single script file and return its metadata"""
    relative_path = str(Path(filepath).relative_to(Path.home()))
    
    # Count lines in file
    num_lines = 0
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            num_lines = sum(1 for line in f)
    except:
        pass
    
    return {
        'file_path': str(filepath),
        'relative_path': relative_path,
        'filename': Path(filepath).name,
        'extension': Path(filepath).suffix,
        'language': detect_language(filepath),
        'category': categorize_script(filepath),
        'size_bytes': get_file_size(filepath),
        'modification_time': get_modification_time(filepath),
        'md5_hash': get_file_hash(filepath),
        'shebang': detect_shebang(filepath),
        'imports': extract_imports(filepath),
        'apis_used': extract_api_keys(filepath),
        'complexity': estimate_complexity(filepath),
        'num_lines': num_lines
    }

def generate_advanced_meta_csv():
    """Generate the advanced meta CSV for the ~/scripts directory"""
    scripts_dir = Path.home() / 'scripts'
    output_file = scripts_dir / 'advanced_scripts_meta.csv'
    
    if not scripts_dir.exists():
        print(f"Directory {scripts_dir} does not exist")
        return
    
    # Get all script files
    script_extensions = ['.sh', '.py', '.js', '.ts', '.go', '.rb', '.pl', '.php', '.lua', '.sql']
    all_scripts = []
    
    for ext in script_extensions:
        all_scripts.extend(scripts_dir.rglob(f'*{ext}'))
    
    # Also include any files that look like scripts based on shebang
    for file_path in scripts_dir.rglob('*'):
        if file_path.is_file() and not file_path.suffix:
            # Check if it has a shebang
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    first_line = f.readline().strip()
                    if first_line.startswith('#!'):
                        all_scripts.append(file_path)
            except:
                continue
    
    # Remove duplicates
    all_scripts = list(set(all_scripts))
    
    print(f"Found {len(all_scripts)} script files to analyze")
    
    # Prepare CSV data
    fieldnames = [
        'file_path', 'relative_path', 'filename', 'extension', 'language', 
        'category', 'size_bytes', 'modification_time', 'md5_hash', 
        'shebang', 'imports', 'apis_used', 'complexity', 'num_lines'
    ]
    
    # Analyze each script and write to CSV
    with open(output_file, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        
        for i, script_path in enumerate(all_scripts, 1):
            try:
                metadata = analyze_script(script_path)
                writer.writerow(metadata)
                
                if i % 50 == 0:
                    print(f"Processed {i}/{len(all_scripts)} scripts...")
                    
            except Exception as e:
                print(f"Error processing {script_path}: {str(e)}")
                continue
    
    print(f"Advanced meta CSV generated: {output_file}")
    print(f"Total scripts analyzed: {len(all_scripts)}")

if __name__ == "__main__":
    generate_advanced_meta_csv()