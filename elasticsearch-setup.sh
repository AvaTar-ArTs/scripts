#!/usr/bin/env bash
# elasticsearch-setup/run_setup.sh

set -e

echo "Starting Elasticsearch Document Indexing Setup..."
echo "================================================"

# Start Elasticsearch and Kibana
echo "Starting Elasticsearch and Kibana containers..."
docker-compose up -d

echo "Waiting for Elasticsearch to be ready..."
sleep 30

# Check if Elasticsearch is running
if curl -s http://localhost:9200 > /dev/null; then
    echo "✓ Elasticsearch is running"
else
    echo "✗ Elasticsearch is not accessible. Please check the container status."
    exit 1
fi

# Create the documents index
echo "Creating 'documents' index..."
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
      }
    }
  }
}' > /dev/null

echo "✓ Index created successfully"

echo ""
echo "Setup complete! You can now:"
echo "1. Access Kibana at http://localhost:5601"
echo "2. Run 'python scripts/index_documents.py' to start indexing your documents"
echo "3. Run 'python scripts/search_documents.py \"search query\"' to search your documents"
echo ""
echo "To stop the services: docker-compose down"
