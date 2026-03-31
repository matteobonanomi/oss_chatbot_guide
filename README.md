# My LibreChat Configuration

**a step by step guide to configure LibreChat from basic to advanced features**

---

## 📋 Overview

This repository contains a production-ready, self-hosted AI personal assistant stack built with open-source software. It provides a fully functional chat interface with advanced features including web search, RAG (Retrieval-Augmented Generation), multi-model routing with fallbacks, and agent capabilities.

![Architecture](architecture.png)

### Components

| Component | Purpose |
|-----------|---------|
| LibreChat | Modern chat interface with AI model support |
| LiteLLM | Unified LLM gateway with intelligent model routing |
| MongoDB | Database for chat history and user data |
| PgVector | Vector database for semantic search and RAG |
| RAG API | Document ingestion and retrieval system |
| SearXNG | Self-hosted web search engine |
| Cloudflare Tunnel | Secure external access without port forwarding |

---

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- OpenRouter API key

### Installation
```bash
cp templates/.env.fake .env
# Edit .env with your credentials
docker compose up -d
```

Access LibreChat at your configured domain.

---

## 📁 Configuration Files

| File | Description |
|------|-------------|
| `.env` | Environment variables (secrets, API keys, settings) |
| `docker-compose.yml` | Service definitions and orchestration |
| `librechat.yaml` | LibreChat interface and model presets |
| `litellm/config.yaml` | LLM model routing and fallbacks |
| `searxng/settings.yml` | Web search engine configuration |

See `templates/.env.fake` for a complete configuration template.

---

## 🏗️ Architecture

```
User Browser → Cloudflare Tunnel → LibreChat
                                      ├─→ LiteLLM → LLMs
                                      ├─→ MongoDB → Chat history
                                      ├─→ RAG API → PgVector
                                      └─→ SearXNG → Web search
```

### Key Features
- **Web Search**: SearXNG (self-hosted) + Serper (scraper) + Jina (reranker)
- **RAG**: BGE-M3 embeddings via OpenRouter → PgVector
- **Model Routing**: Multi-tier presets (Small/Medium/Large) with automatic fallbacks

---

## 📄 License

MIT License - Compatible with all component licenses:
- LibreChat: MIT
- LiteLLM: MIT
- MongoDB: SSPL
- PostgreSQL/PgVector: PostgreSQL License
- SearXNG: AGPL-3.0

---

## 🛠️ Maintenance

```bash
# Check status
docker compose ps

# View logs
docker compose logs -f

# Update
docker compose pull && docker compose up -d
```

---

## 📚 Resources

- [LibreChat Docs](https://docs.librechat.ai/)
- [LiteLLM Docs](https://docs.litellm.ai/)
- [Detailed Guide](docs/docs_librechat.pdf)

---

**Happy Chatting with your Self-Hosted AI Stack!**
