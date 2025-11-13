# Cognee Coolify Deployment Guide (CORRECTED)
**Date: November 13, 2025**

## 🚨 The Problem with Coolify Auto-Generation

When Coolify reads your docker-compose.yaml, it was incorrectly assigning **ALL services to port 6333**:
- `SERVICE_FQDN_COGNEE=...v1su4.com:6333` ❌ 
- `SERVICE_FQDN_NEO4J=...v1su4.com:6333` ❌
- `SERVICE_FQDN_QDRANT=...v1su4.com:6333` ❌

This is WRONG! Each service needs its own port.

## ✅ Correct Configuration

### Service Port Mapping

| Service | Domain | Port | Purpose |
|---------|--------|------|---------|
| **Cognee** | `cognee.v1su4.com` | 8000 | Main API |
| **Neo4j** | `neo4j-cognee.v1su4.com` | 7474 | Graph database browser |
| **Qdrant** | `qdrant-cognee.v1su4.com` | 6333 | Vector database dashboard |
| **Postgres** | Internal only | 5432 | Relational database (not exposed) |

### Updated docker-compose.yaml

The corrected `docker-compose.yaml` now has:

```yaml
services:
  cognee:
    environment:
      - SERVICE_FQDN_COGNEE_8000=cognee.v1su4.com
      # ... other vars
  
  neo4j:
    environment:
      - SERVICE_FQDN_NEO4J_7474=neo4j-cognee.v1su4.com
      # ... other vars
  
  qdrant:
    environment:
      - SERVICE_FQDN_QDRANT_6333=qdrant-cognee.v1su4.com
      # ... other vars
```

## 🔧 How Coolify SERVICE_FQDN Works

When Coolify sees `SERVICE_FQDN_<SERVICE>_<PORT>=<domain>`, it:

1. **Creates a Traefik route** for that service on the specified port
2. **Sets up SSL** via Let's Encrypt for HTTPS
3. **Proxies traffic** from `https://<domain>` to the internal container port

### Example:
```yaml
environment:
  - SERVICE_FQDN_COGNEE_8000=cognee.v1su4.com
```

This tells Coolify:
- Service name: `COGNEE`
- Internal port: `8000`
- Public domain: `cognee.v1su4.com`
- Result: `https://cognee.v1su4.com` → `http://cognee:8000` (internal)

## 📝 Deployment Steps

### 1. Delete Your Old Instance
Since you mentioned deleting and recreating:
1. In Coolify, go to your Cognee project
2. Click **Delete Resource**
3. Confirm deletion (this removes containers, but volumes persist)

### 2. Prepare Your Configuration

Copy the corrected `.env.coolify` file:

```bash
cp .env.coolify .env
```

Then edit `.env` and fill in:
- `LLM_API_KEY` - Your OpenAI API key
- `EMBEDDING_API_KEY` - Same as LLM_API_KEY
- `NEO4J_PASSWORD` - Strong password for Neo4j
- `POSTGRES_PASSWORD` - Strong password for Postgres

### 3. Push to Git

```bash
git add docker-compose.yaml .env
git commit -m "Fix Coolify SERVICE_FQDN configuration with correct ports"
git push origin main
```

### 4. Create New Resource in Coolify

1. Go to **Projects** → Your project
2. Click **Add Resource**
3. Choose **Docker Compose**
4. Select your Git repository
5. Branch: `main`
6. Coolify will detect `docker-compose.yaml`

### 5. Configure Environment Variables in Coolify

In the Coolify UI, add these environment variables:

```bash
# Required
LLM_API_KEY=sk-...your-key...
EMBEDDING_API_KEY=sk-...your-key...
NEO4J_PASSWORD=your-strong-password
POSTGRES_PASSWORD=another-strong-password

# Optional (defaults are good)
LLM_MODEL=gpt-5.1
EMBEDDING_MODEL=text-embedding-3-small
NEO4J_HEAP_SIZE=2G
NEO4J_PAGECACHE_SIZE=2G
VECTOR_DB_PROVIDER=qdrant
COGNEE_ENV=production
LOG_LEVEL=INFO
```

### 6. Deploy

1. Click **Deploy** in Coolify
2. Watch the logs for any errors
3. Wait for all services to be healthy

## 🎯 Accessing Your Services

After deployment, your services will be available at:

- **Main API**: `https://cognee.v1su4.com`
- **Neo4j Browser**: `https://neo4j-cognee.v1su4.com`
  - Username: `neo4j`
  - Password: (your NEO4J_PASSWORD)
- **Qdrant Dashboard**: `https://qdrant-cognee.v1su4.com`

## 🔍 Key Changes Made

### 1. Fixed SERVICE_FQDN Variables
**Before:**
```yaml
- SERVICE_FQDN_QDRANT_6333
```

**After:**
```yaml
- SERVICE_FQDN_QDRANT_6333=qdrant-cognee.v1su4.com
```

### 2. Added Health Checks
- **Qdrant** now has a proper healthcheck on `/healthz`
- **Neo4j** healthcheck improved with better timing
- All services use `condition: service_healthy` for proper startup order

### 3. Updated Neo4j Configuration
Added production-ready settings from official docs:
```yaml
- NEO4J_server_memory_pagecache_size=2G
- NEO4J_dbms_transaction_timeout=120s
```

### 4. Fixed Graph Database Environment Variables
Changed from:
```yaml
- GRAPH_DB_PROVIDER=neo4j
- NEO4J_URI=bolt://neo4j:7687
```

To official Cognee format:
```yaml
- GRAPH_DATABASE_PROVIDER=neo4j
- GRAPH_DATABASE_URL=bolt://neo4j:7687
- GRAPH_DATABASE_USERNAME=neo4j
- GRAPH_DATABASE_PASSWORD=${NEO4J_PASSWORD}
```

### 5. Updated to GPT-5.1
Changed default model from `gpt-4` to `gpt-5.1` (released Nov 13, 2025)

## 🐛 Troubleshooting

### Issue: "Connection refused" errors
**Solution:** Check that all services are healthy:
```bash
docker ps
```

### Issue: "SSL certificate not found"
**Solution:** Coolify generates SSL certs automatically via Let's Encrypt. Wait 1-2 minutes after deployment.

### Issue: Neo4j won't start
**Solution:** Check heap size. 2G minimum required. If your server has <4GB RAM, reduce to 1G.

### Issue: Can't access services
**Solution:** Verify DNS is pointing to your Coolify server:
```bash
nslookup cognee.v1su4.com
nslookup neo4j-cognee.v1su4.com
nslookup qdrant-cognee.v1su4.com
```

## 📚 Official Documentation References

- [Cognee Distributed Setup](https://www.cognee.ai/blog/cognee-news/scaling-intelligence-introducing-distributed-cognee-for-parallel-dataset-processing)
- [Cognee Docs - Installation](https://docs.cognee.ai/getting-started/installation)
- [Neo4j Docker Documentation](https://neo4j.com/docs/operations-manual/current/docker/)
- [Qdrant Documentation](https://qdrant.tech/documentation/)
- [Coolify SERVICE_FQDN Documentation](https://coolify.io/docs/knowledge-base/docker/compose#service-discovery)

## 🎉 Summary

You now have:
- ✅ Correct port assignments for all services
- ✅ Proper domain configuration
- ✅ Health checks for reliability
- ✅ Production-ready Neo4j settings
- ✅ Latest GPT-5.1 model support
- ✅ SSL/HTTPS enabled via Coolify

Your Cognee stack is ready for production use! 🚀
