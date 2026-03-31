# My LibreChat Configuration

**a step by step guide to configure LibreChat from basic to advanced features**

---

## 📋 Overview

This repository contains a production-ready, self-hosted AI personal assistant stack built with open-source software. It provides a fully functional chat interface with advanced features including web search, RAG (Retrieval-Augmented Generation), multi-model routing with fallbacks, and agent capabilities.

The configuration is designed for easy deployment and customization, following a progressive approach that starts with basic features and extends to advanced capabilities like deep reasoning, web research, and document processing.

### What's Included

| Component | Purpose |
|-----------|---------|
| **LibreChat** | Modern chat interface with AI model support |
| **LiteLLM** | Unified LLM gateway with intelligent model routing |
| **MongoDB** | Database for chat history and user data |
| **PgVector** | Vector database for semantic search and RAG |
| **RAG API** | Document ingestion and retrieval system |
| **SearXNG** | Self-hosted web search engine |
| **Cloudflare Tunnel** | Secure external access without port forwarding |

---

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed ([guide](https://docs.docker.com/get-docker/))
- OpenRouter API key ([get one here](https://openrouter.ai/))
- Basic understanding of Docker concepts

### Installation Steps

1. **Clone or copy this repository** to your target machine:
   ```bash
   cd /home/your-user/
   # Copy or clone this repository here
   ```

2. **Create your environment file** by copying the template:
   ```bash
   cp templates/.env.fake .env
   ```

3. **Edit `.env` with your credentials**:
   - Set your OpenRouter API key
   - Generate secure cryptographic keys (see [Security Configuration](#security-configuration))
   - Configure your domain URL
   - Set up web search API keys (optional for basic RAG)

4. **Start the services**:
   ```bash
   docker compose up -d
   ```

5. **Access LibreChat** at your configured domain (e.g., `https://chat.yourdomain.com`)

### First Login

- Register a new account or configure email login
- Upload documents to test RAG capabilities
- Try the WebSearch agent template in the Agents section

---

## 🏗️ Architecture

```
                                    ┌─────────────────┐
                                    │   User Browser  │
                                    └────────┬────────┘
                                             │
                                    ┌────────┴────────┐
                                    │ Cloudflare Tunnel│
                                    └────────┬────────┘
                                             │
                     ┌───────────────────────┼───────────────────────┐
                     │                       │                       │
             ┌───────▼────────┐      ┌───────▼────────┐      ┌───────▼────────┐
             │   LibreChat    │      │   SearXNG      │      │   Cloudflare   │
             │   (Port 3080)  │      │   (Port 8080)  │      │   Tunnel       │
             └────────┬───────┘      └────────────────┘      └────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
┌───────▼───────┐ ┌───▼───────┐ ┌───▼───────┐
│    MongoDB    │ │  LiteLLM  │ │  RAG API  │
│   (MongoDB)   │ │   (4000)  │ │   (8000)  │
└───────────────┘ └─────┬─────┘ └─────┬─────┘
                        │             │
                  ┌─────┴─────┐ ┌─────┴─────┐
                  │  PgVector │ │   Mongo   │
                  │  (PG16)   │ │  (MongoDB)│
                  └───────────┘ └───────────┘
```

### Data Flow

1. **User interactions** flow through Cloudflare Tunnel to LibreChat
2. **Model requests** are routed through LiteLLM with intelligent fallbacks
3. **Document ingestion** uses RAG API with BGE-M3 embeddings via LiteLLM
4. **Web search** uses SearXNG (self-hosted) with Serper scraper and Jina reranker

---

## 📁 Configuration Files

### `.env` - Environment Variables

The main configuration file containing all secrets and system settings.

| Section | Variables | Description |
|---------|-----------|-------------|
| **LibreChat** | PUBLIC_URL, CREDS_KEY, JWT_SECRET, etc. | Core LibreChat configuration |
| **Cloudflare** | CLOUDFLARE_TUNNEL_TOKEN | Secure tunnel configuration |
| **LiteLLM** | LITELLM_MASTER_KEY | API key for proxy access |
| **OpenRouter** | OPENROUTER_API_KEY | Primary LLM provider |
| **RAG** | RAG_POSTGRES_*, RAG_CHUNK_SIZE, etc. | Vector database and embeddings |
| **Web Search** | SEARXNG_*, SERPER_*, JINA_* | Search and scraping configuration |

**Important**: Never commit `.env` to version control. Use `.env.fake` as a template for configuration examples.

---

### `docker-compose.yml` - Service Configuration

The main Orchestration file defining all services and their configurations.

**Key services**:
- `mongodb`: Chat history and user data
- `vectordb`: PgVector for semantic search
- `litellm`: Unified LLM gateway
- `rag_api`: Document processing and retrieval
- `searxng`: Self-hosted search engine
- `librechat`: Main chat interface
- `cloudflared`: Secure external access

**Networks**: All services communicate via internal Docker network (`internal`)

**Volumes**:
- `mongo_data`: MongoDB persistence
- `rag_pg_data`: PgVector persistence
- `rag_uploads`: Document upload storage

---

### `librechat.yaml` - LibreChat Configuration

Detailed configuration for LibreChat features:

**Interface Settings**:
- File search and web search enabled
- Agent mode enabled with creation capabilities
- Presets visible for easy model selection

**Model Specs** - Preset configurations:
| Preset | Model | Max Tokens | Best For |
|--------|-------|------------|----------|
| `small-no-reasoning` | Qwen 4B | 384 | Quick tasks, no reasoning |
| `small-light` | Qwen 8B | 512 | Light tasks with reasoning |
| `medium-balanced` | Qwen 14B | 640 | Balanced quality/speed |
| `medium-deep` | Qwen 32B | 768 | Deep reasoning tasks |
| `large-balanced` | Qwen 80B | 768 | High quality, fast response |
| `large-max` | Qwen 122B | 896 | Maximum quality and reasoning |

**Web Search Configuration**:
- SearXNG self-hosted search
- Serper scraper for content extraction
- Jina reranker for relevance scoring

**File Configuration**:
- PDF, text, Word documents supported
- 25MB individual file limit
- 75MB total per chat (configurable per endpoint)

---

### `litellm/config.yaml` - Model Routing

Advanced model configuration with intelligent fallbacks.

**Preset Groups**:
- **SMALL**: Qwen 4B, 8B (free and paid versions)
- **MEDIUM**: Qwen 14B, 32B, Mistral Small
- **LARGE**: Qwen 80B, 122B, Llama 3.3 70B

**Features**:
- 4 max fallbacks per request
- Model-specific rate limiting
- Context window management
- Reasoning model support detection
- cost optimization via free tier priorty

**Fallback Configuration**:
```
small_plain → small_plain_paid → small_plain_backup1
small_light → small_light_paid → small_light_backup1 → small_light_backup2
...
```

---

## 🔧 Configuration Guide

### Basic Setup (Minimum Viable)

1. Create `.env` from `.env.fake`
2. Set minimal required values:
   ```env
   OPENROUTER_API_KEY=your_key_here
   PUBLIC_URL=your_domain.com
   LITELLM_MASTER_KEY=sk-unique_string_here
   JWT_SECRET=strong_random_string
   ```
3. Run: `docker compose up -d`

### Advanced Configuration

#### Enable Web Search

1. Get Serper API key (no monthly subscription)
2. Get Jina API key for reranking
3. Add to `.env`:
   ```env
   SERPER_API_KEY=your_serper_key
   JINA_API_KEY=your_jina_key
   ```

#### Custom RAG Settings

Adjust in `.env`:
```env
RAG_CHUNK_SIZE=512        # Smaller chunks for more precise retrieval
RAG_CHUNK_OVERLAP=64      # Less overlap
RAG_EMBEDDING_BATCH_SIZE=32  # Lower memory usage
```

#### Security hardened setup

1. Generate strong cryptographic keys
2. Set `ALLOW_REGISTRATION=false`
3. Configure email login or OAuth
4. Enable Cloudflare Tunnel for HTTPS

### Presets and Model Selection

Presets are predefined configurations accessible from LibreChat's interface. Each preset maps to specific LiteLLM model names and context limits.

**To create a new preset**:
1. Add models to `litellm/config.yaml` with backup list
2. Define model specs in `librechat.yaml`
3. Restart services

---

## 🔍 Web Search Capabilities

### How It Works

1. User asks a question requiring current information
2. SearXNG queries multiple search engines
3. Serper extracts content from search results
4. Jina reranks results by relevance
5. Top results added as context to LLM
6. LLM generates answer with citations

### Use Cases

- Technical documentation lookup
- Current events and news
- Academic paper search
- Product comparison
- Recipe finding

### Configuration

Set web search parameters in `librechat.yaml`:
```yaml
webSearch:
  maxResults: 2          # Number of search results
  resultCount: 2         # Results passed to LLM
  safeSearch: 1          # Moderate filtering
  scraperTimeout: 12000  # 12 seconds max per scraper
```

---

## 🗂️ RAG (Retrieval-Augmented Generation)

### Supported Document Types

- PDF documents
- Text files (plain, markdown, CSV)
- JSON and XML
- Word documents (.docx, .doc)

### Embeddings

- **Model**: BGE-M3 via OpenRouter
- **Dimensions**: 1024
- **Max tokens**: 5120
- **Vector DB**: PgVector (PostgreSQL extension)

### Usage Workflow

1. Upload document via LibreChat interface
2. RAG API splits into chunks (default: 1000 chars)
3. Each chunk embedded via BGE-M3
4. Embeddings stored in PgVector
5. Query time: relevant chunks retrieved + LLM generation

### Performance Tuning

**For faster indexing** (higher RAM):
```env
RAG_EMBEDDING_BATCH_SIZE=128
RAG_EMBEDDING_MAX_QUEUE_SIZE=4
```

**For better retrieval** (more chunks):
```env
RAG_CHUNK_SIZE=512
RAG_CHUNK_OVERLAP=50
```

---

## 🤖 Agents

### WebSearch Agent

A research-focused agent template included in `templates/agents/`.

**Features**:
- Uses reasoning models by default
- Web search enabled
- Source citations
- Transparency and explainability focus

**Configuration**:
- Model: `medium_balanced`
- Tools: `web_search`
- Max recursion: 50 steps

### Creating Custom Agents

1. Save agent template in `templates/agents/`
2. Restart LibreChat or use API
3. Agent appears in interface

---

## 🔐 Security Configuration

### Environment Keys

Generate secure keys for production:

```bash
# JWT Secret (64 bytes hex)
openssl rand -hex 64

# CREDS_KEY (32 bytes hex)
openssl rand -hex 32

# CREDS_IV (16 bytes hex)
openssl rand -hex 16

# JWT Refresh Secret (64 bytes hex)
openssl rand -hex 64

# SearXNG Secret (32 bytes hex)
openssl rand -hex 32
```

### Security Checklist

- [ ] Set strong cryptographic keys
- [ ] Disable registration if using email login
- [ ] Use Cloudflare Tunnel for HTTPS
- [ ] Regular backup of volumes (`mongo_data`, `rag_pg_data`)
- [ ] Never expose MongoDB and pgvector directly to internet
- [ ] Update API keys periodically
- [ ] Monitor Docker logs for security events

---

## 🛠️ Maintenance

### Daily Operations

```bash
# Check service status
docker compose ps

# View logs
docker compose logs -f

# Restart specific service
docker compose restart librechat
```

### Backups

**MongoDB**:
```bash
docker compose exec mongodb mongodump --out /dump
docker cp ai-stack-mongodb-1:/dump ./mongodb-backup-$(date +%Y%m%d)
```

**PgVector**:
```bash
docker compose exec vectordb pg_dump -U rag rag_api > rag_backup_$(date +%Y%m%d).sql
```

### Updates

```bash
# Stop services
docker compose down

# Pull latest images
docker compose pull

# Restart
docker compose up -d
```

---

## 🔧 Troubleshooting

### Common Issues

**LibreChat won't start**:
- Check MongoDB is running: `docker compose logs mongodb`
- Verify `.env` values are correct
- Check Docker daemon is running

**RAG embeddings fail**:
- Verify LiteLLM is accessible: `curl http://localhost:4000/v1/models`
- Check RAG_API_URL in `.env` matches `http://rag_api:8000`
- Review logs: `docker compose logs rag_api`

**Web search not working**:
- Verify SearXNG is running: `docker compose logs searxng`
- Check SEARXNG_INSTANCE_URL matches `http://searxng:8080`
- Test Serper API key independently

### Debug Mode

Enable in `.env`:
```env
DEBUG_RAG_API=True
DEBUG_PGVECTOR_QUERIES=True
```

Then restart and check detailed logs.

---

## 📚 Documentation

### Official Documentation

- [LibreChat Documentation](https://docs.librechat.ai/)
- [LiteLLM Documentation](https://docs.litellm.ai/)
- [PgVector Documentation](https://pgvector.org/)

### Configuration Examples

See `templates/.env.fake` for complete configuration template with explanations.

---

## 🤝 Contributing

This repository follows the [oss_chatbot_guide](https://github.com/matteobonanomi/oss_chatbot_guide) project.

Contributions welcome for:
- Configuration improvements
- Feature documentation
- Troubleshooting guides
- Example prompts and agents

---

## 📄 License

This configuration repository is provided as-is for educational and personal use.

---

## 🙏 Acknowledgments

- LibreChat team for the amazing chat interface
- LiteLLM team for the LLM gateway
- Community contributors and users

---

## 📞 Support

For issues:
1. Check the [Troubleshooting](#-troubleshooting) section
2. Review Docker logs: `docker compose logs`
3. Test individual services in isolation
4. Consult official component documentation

---

**Happy Chatting with your Self-Hosted AI Stack!** 🎉
