#!/bin/bash
# Test file upload with debug logging

docker compose logs rag_api 2>&1 > /tmp/rag_logs_before.txt
echo "Testing file upload to check if OpenRouter embeddings work..."
echo "Please upload a test file via the web interface and then run:"
echo "docker compose logs rag_api --tail 30 2>&1 | grep -E 'http://litellm|https://api.openai'"
