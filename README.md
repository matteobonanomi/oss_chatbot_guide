# AI Stack

Self-hosted AI personal assistant stack built with open-source software.

## Components

- **LibreChat** - Chatbot interface with AI model support
- **LiteLLM** - Unified LLM gateway for multiple providers
- **MongoDB** - Database for chat history and user data
- **PgVector** - Vector database for RAG (retrieval-augmented generation)
- **RAG API** - Document ingestion and semantic search
- **Cloudflare Tunnel** - Secure external access

## Quick Start

```bash
docker-compose up -d
```

See the full documentation for configuration details.

## Embeddings Configuration

The RAG API is configured to use **BGE-M3** embeddings via OpenRouter through LiteLLM:

- **Model**: `baai/bge-m3` (1024 dimensions, 5120 token limit)
- **Endpoint**: `http://litellm:4000/v1/embeddings`

### Configuration Files:
- `.env` - RAG_API environment variables
- `docker-compose.yml` - Service configuration
- `litellm/config.yaml` - LiteLLM model routing

### To Test:
1. Upload a PDF via the LibreChat web interface
2. Check logs: `docker compose logs rag_api --tail 20 2>&1 | grep "litellm"`
3. Verify no 401 errors and calls to `http://litellm:4000/v1/embeddings`
