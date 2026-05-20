#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# AI Content Automation Setup Script
# ==================================

echo "🚀 Setting up AI Content Automation with Make.com + Airtable"
echo "============================================================="

# Check if required tools are installed
check_dependencies() {
    echo "🔍 Checking dependencies..."
    
    if ! command -v python3 &> /dev/null; then
        echo "❌ Python3 is required but not installed."
        exit 1
    fi
    
    if ! command -v pip3 &> /dev/null; then
        echo "❌ pip3 is required but not installed."
        exit 1
    fi
    
    if ! command -v ngrok &> /dev/null; then
        echo "⚠️  ngrok not found. Installing..."
        # Install ngrok (macOS)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install ngrok/ngrok/ngrok
        else
            echo "Please install ngrok manually: https://ngrok.com/download"
        fi
    fi
    
    echo "✅ Dependencies check complete"
}

# Install Python dependencies
install_python_deps() {
    echo "📦 Installing Python dependencies..."
    
    pip3 install flask requests python-dotenv
    
    echo "✅ Python dependencies installed"
}

# Create Airtable base template
create_airtable_template() {
    echo "📊 Creating Airtable base template..."
    
    cat > airtable_base_template.json << 'EOF'
{
  "name": "AI Content Automation",
  "tables": [
    {
      "name": "Content Requests",
      "fields": [
        {"name": "Title", "type": "singleLineText"},
        {"name": "Content Type", "type": "singleSelect", "options": ["Blog Post", "Video Script", "Audio Book", "Social Media", "Email", "Documentation"]},
        {"name": "Priority", "type": "singleSelect", "options": ["High", "Medium", "Low"]},
        {"name": "Status", "type": "singleSelect", "options": ["New", "In Progress", "Review", "Complete", "Published"]},
        {"name": "Description", "type": "multilineText"},
        {"name": "Target Audience", "type": "singleLineText"},
        {"name": "Tone", "type": "singleSelect", "options": ["Professional", "Casual", "Technical", "Creative", "Formal"]},
        {"name": "Word Count", "type": "number"},
        {"name": "Keywords", "type": "multipleSelects", "options": []},
        {"name": "Due Date", "type": "date"},
        {"name": "Client", "type": "singleLineText"},
        {"name": "Budget", "type": "currency"},
        {"name": "AI Models Used", "type": "multipleSelects", "options": ["OpenAI", "Anthropic", "Stability AI", "ElevenLabs", "Leonardo AI"]},
        {"name": "Generated Content", "type": "multilineText"},
        {"name": "Audio File", "type": "multipleAttachments"},
        {"name": "Image Files", "type": "multipleAttachments"},
        {"name": "Notes", "type": "multilineText"}
      ]
    },
    {
      "name": "AI Services Status",
      "fields": [
        {"name": "Service Name", "type": "singleLineText"},
        {"name": "Status", "type": "singleSelect", "options": ["Active", "Inactive", "Error"]},
        {"name": "Last Used", "type": "date"},
        {"name": "Usage Count", "type": "number"},
        {"name": "Error Rate", "type": "number"},
        {"name": "Cost This Month", "type": "currency"},
        {"name": "API Key Status", "type": "singleSelect", "options": ["Valid", "Invalid", "Expired"]},
        {"name": "Rate Limits", "type": "number"},
        {"name": "Notes", "type": "multilineText"}
      ]
    },
    {
      "name": "Generated Assets",
      "fields": [
        {"name": "Asset Name", "type": "singleLineText"},
        {"name": "Asset Type", "type": "singleSelect", "options": ["Audio", "Image", "Video", "Text", "Document"]},
        {"name": "Source Content", "type": "linkToAnotherRecord", "linkToTable": "Content Requests"},
        {"name": "File Size", "type": "number"},
        {"name": "Duration", "type": "duration"},
        {"name": "Quality", "type": "singleSelect", "options": ["High", "Medium", "Low"]},
        {"name": "Storage Location", "type": "singleLineText"},
        {"name": "Public URL", "type": "url"},
        {"name": "Created Date", "type": "date"},
        {"name": "AI Model Used", "type": "singleLineText"},
        {"name": "Processing Time", "type": "duration"}
      ]
    },
    {
      "name": "Workflow Logs",
      "fields": [
        {"name": "Timestamp", "type": "date"},
        {"name": "Action", "type": "singleLineText"},
        {"name": "Content Request", "type": "linkToAnotherRecord", "linkToTable": "Content Requests"},
        {"name": "Status", "type": "singleSelect", "options": ["Success", "Error", "Warning"]},
        {"name": "Details", "type": "multilineText"},
        {"name": "AI Service", "type": "singleLineText"},
        {"name": "Processing Time", "type": "duration"},
        {"name": "Error Message", "type": "multilineText"}
      ]
    }
  ]
}
EOF
    
    echo "✅ Airtable base template created: airtable_base_template.json"
    echo "📝 Import this template into Airtable to create your base"
}

# Start the webhook server
start_webhook_server() {
    echo "🌐 Starting webhook server..."
    
    # Make the script executable
    chmod +x ai_webhook_server.py
    
    echo "🚀 Starting AI Webhook Server on port 5000..."
    echo "📡 In another terminal, run: ngrok http 5000"
    echo "🔗 Use the ngrok URL in your Make.com scenarios"
    
    python3 ai_webhook_server.py
}

# Main setup function
main() {
    echo "🎯 AI Content Automation Setup"
    echo "=============================="
    echo ""
    echo "This script will:"
    echo "1. Check dependencies"
    echo "2. Install Python packages"
    echo "3. Create Airtable base template"
    echo "4. Start the webhook server"
    echo ""
    
    read -p "Continue? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 1
    fi
    
    check_dependencies
    install_python_deps
    create_airtable_template
    
    echo ""
    echo "🎉 Setup complete!"
    echo ""
    echo "Next steps:"
    echo "1. Import airtable_base_template.json into Airtable"
    echo "2. Get your Airtable base ID and API key"
    echo "3. Update make_com_scenarios.json with your credentials"
    echo "4. Import scenarios into Make.com"
    echo "5. Run: ngrok http 5000 (in another terminal)"
    echo "6. Start the webhook server: python3 ai_webhook_server.py"
    echo ""
    echo "Ready to start the webhook server? (y/n)"
    read -p "> " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        start_webhook_server
    else
        echo "Run 'python3 ai_webhook_server.py' when ready!"
    fi
}

# Run main function
main
