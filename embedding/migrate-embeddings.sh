#!/bin/bash
set -e

echo "=== LibreChat Embeddings Migration to BGE-M3 ==="
echo "Model: baai/bge-m3 (1024 dimensions)"
echo

# 1. Backup pgvector
echo "[1/6] Backing up pgvector database..."
docker compose exec -T vectordb pg_dump -U rag -d rag_api > ~/rag_backup_$(date +%Y%m%d_%H%M%S).sql
echo "✓ Backup saved to ~/rag_backup_*.sql"

# 2. Stop services
echo
echo "[2/6] Stopping RAG and LibreChat services..."
docker compose stop rag_api librechat
echo "✓ Services stopped"

# 3. Drop old embeddings collection (1536-dim OpenAI)
echo
echo "[3/6] Dropping old embeddings (collection: librechat, 1536-dim)..."
docker compose exec -T vectordb psql -U rag -d rag_api -c "DROP TABLE IF EXISTS librechat_embeddings CASCADE;"
docker compose exec -T vectordb psql -U rag -d rag_api -c "DROP TABLE IF EXISTS librechat_metadata CASCADE;"
echo "✓ Old embeddings dropped"

# 4. Verify cleanup
echo
echo "[4/6] Verifying cleanup..."
docker compose exec -T vectordb psql -U rag -d rag_api -c "\dt"
echo "✓ Verification complete"

# 5. Restart services
echo
echo "[5/6] Starting services..."
docker compose up -d litellm rag_api librechat
echo "✓ Services started"

# 6. Wait and verify
echo
echo "[6/6] Waiting for RAG API to initialize..."
sleep 10
echo
echo "Checking RAG API logs for BGE-M3 initialization..."
docker compose logs rag_api 2>&1 | grep -i "embed" || true
echo
echo "✓ Monitor with: docker logs -f ai-stack-rag_api-1"
echo "✓ Look for: 'Embedding model initialized: bge-m3'"

echo
echo "=== Migration Complete ==="
echo "Next: Upload a test document and verify embeddings are created"
echo "Note: BGE-M3 uses 1024 dimensions (different from previous 1536-dim OpenAI model)"
