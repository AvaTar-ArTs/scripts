#!/usr/bin/env bash
# elasticsearch-setup-improved/setup_system.sh

set -e

echo "Starting Enhanced Elasticsearch Document Indexing System with AutoTagger Integration..."
echo "====================================================================================="

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "✗ Docker is not installed or not in PATH"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "✗ Docker Compose is not installed or not in PATH"
    exit 1
fi

# Start Elasticsearch and Kibana
echo "Starting Elasticsearch and Kibana containers..."
docker-compose up -d

echo "Waiting for Elasticsearch to be ready..."
sleep 45

# Check if Elasticsearch is running
if curl -s http://localhost:9200 > /dev/null; then
    echo "✓ Elasticsearch is running"
else
    echo "✗ Elasticsearch is not accessible. Please check the container status."
    docker-compose logs elasticsearch
    exit 1
fi

# Create the documents index with enhanced mappings
echo "Creating 'documents' index with semantic analysis mappings..."
curl -X PUT "localhost:9200/documents" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0,
    "analysis": {
      "analyzer": {
        "document_analyzer": {
          "type": "custom",
          "tokenizer": "standard",
          "filter": [
            "lowercase",
            "stop",
            "snowball"
          ]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "title": {
        "type": "text",
        "analyzer": "document_analyzer"
      },
      "content": {
        "type": "text",
        "analyzer": "document_analyzer"
      },
      "file_path": {
        "type": "keyword"
      },
      "file_type": {
        "type": "keyword"
      },
      "created_date": {
        "type": "date"
      },
      "modified_date": {
        "type": "date"
      },
      "size_bytes": {
        "type": "long"
      },
      "tags": {
        "type": "keyword"
      },
      "category": {
        "type": "keyword"
      },
      "business_value": {
        "type": "float"
      },
      "complexity": {
        "type": "keyword"
      },
      "semantic_scores": {
        "type": "object",
        "properties": {
          "AI/ML": {"type": "float"},
          "Web Development": {"type": "float"},
          "Automation Scripts": {"type": "float"},
          "Data Analysis": {"type": "float"},
          "Creative Tools": {"type": "float"},
          "Business Operations": {"type": "float"},
          "General": {"type": "float"}
        }
      }
    }
  }
}' > /dev/null

echo "✓ Enhanced index created successfully"

# Check if AutoTagger exists
if [ -d "$HOME/AutoTagger" ]; then
    echo "✓ AutoTagger system detected at $HOME/AutoTagger"
    echo "  AutoTagger will be integrated for semantic analysis"
else
    echo "! AutoTagger system not found at $HOME/AutoTagger"
    echo "  The system will still work but without semantic categorization"
fi

echo ""
echo "Setup complete! You can now:"
echo "1. Access Kibana at http://localhost:5601"
echo "2. Run 'python scripts/index_documents_with_autotag.py' to start indexing your documents"
echo "3. Run 'python scripts/search_documents_enhanced.py' to search your documents"
echo ""
echo "To stop the services: docker-compose down"
echo ""
echo "For continuous indexing, consider setting up a cron job or systemd service."
