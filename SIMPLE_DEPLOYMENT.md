# Simple Cognee Deployment Guide - Docker Image Method

**Goal**: Get Cognee API endpoints working ASAP for your MCP server with Goose IDE.

## Why This Method is Better

❌ **GitHub Deployment Issues:**
- Complex SERVICE_FQDN configuration
- Build failures
- Port conflicts with Coolify
- Too many moving parts

✅ **Docker Image Deployment:**
- **5 minutes to deploy**
- No build issues
- Simple domain configuration
- Just works™

## Step 1: Build Your Docker Image Locally

```bash
# Build the image
cd cognee
docker build -t cognee-api:latest .

# Test it locally
docker run -p 3000:3000 \
  -e LLM_API_KEY=your-key \
  -e EMBEDDING_API_KEY=your-key \
  -e POSTGRES_PASSWORD=test \
  -e NEO4J_PASSWORD=test \
  cognee-api:latest

# Test endpoint
curl http://localhost:3000/health
# Should return: {"status":"healthy","service":"cognee-api"}
```

## Step 2: Push to Docker Hub (Optional)

```bash
# Login to Docker Hub
docker login

# Tag your image
docker tag cognee-api:latest yourusername/cognee-api:latest

# Push to Docker Hub
docker push yourusername/cognee-api:latest
```

**OR** use local Coolify registry (simpler):
- Coolify can build and store images internally
- No Docker Hub account needed

## Step 3: Deploy in Coolify

### Option A: Use Coolify's Simple Docker Image Deployment

1. **In Coolify Dashboard**:
   - Click "**+ Add Resource**"
   - Choose "**Docker Image**" (NOT Docker Compose)
   - Image: `yourusername/cognee-api:latest` (or local build)

2. **Set Environment Variables**:
   ```bash
   LLM_API_KEY=sk-proj-your-openai-key
   EMBEDDING_API_KEY=sk-proj-your-openai-key
   NEO4J_PASSWORD=your-secure-password
   POSTGRES_PASSWORD=your-secure-password
   
   # Optional
   LLM_MODEL=gpt-4
   EMBEDDING_MODEL=text-embedding-3-small
   LOG_LEVEL=INFO
   COGNEE_ENV=production
   ```

3. **Set Port**:
   - **Port Exposes**: `3000`

4. **Set Domain**:
   - **Domain**: `https://cognee.v1su4.com:3000`

5. **Deploy!**

### Option B: Use Simple Docker Compose

1. **In Coolify Dashboard**:
   - Click "**+ Add Resource**"
   - Choose "**Docker Compose**"
   - Paste the content of `docker-compose.simple.yaml`

2. **Configure Domains in Coolify UI** (NOT in compose file):
   - **Cognee**: `https://cognee.v1su4.com:3000`
   - **Neo4j**: `https://neo4j-cognee.v1su4.com:7474` (optional)
   - **Qdrant**: `https://qdrant-cognee.v1su4.com:6333` (optional)

3. **Set Environment Variables** in Coolify UI

4. **Deploy!**

## Step 4: Test Your Endpoints

```bash
# Health check
curl https://cognee.v1su4.com/health
# Expected: {"status":"healthy","service":"cognee-api"}

# Status
curl https://cognee.v1su4.com/status

# API Docs
open https://cognee.v1su4.com/docs

# Test add data
curl -X POST https://cognee.v1su4.com/add \
  -H "Content-Type: application/json" \
  -d '{"data": "Test message", "dataset_name": "test"}'
```

## Step 5: Configure Goose MCP

Update your Goose configuration to use your production endpoint:

**`~/.config/goose/profiles.yaml`:**
```yaml
mcp_servers:
  cognee:
    command: uv
    args:
      - --directory
      - /path/to/cognee-mcp
      - run
      - python
      - src/server.py
    env:
      COGNEE_API_URL: https://cognee.v1su4.com  # Your production endpoint!
      LLM_API_KEY: ${LLM_API_KEY}
      EMBEDDING_API_KEY: ${EMBEDDING_API_KEY}
```

**Test Goose:**
```bash
goose session start
# In Goose: "Add this to Cognee: My deployment finally works!"
```

## Troubleshooting

### Issue: "Connection refused"
**Fix**: Check firewall allows ports 80, 443
```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### Issue: "SSL certificate error"
**Fix**: Wait 2-5 minutes for Let's Encrypt certificate generation

### Issue: "404 Not Found"
**Fix**: Verify domain configuration in Coolify UI includes port `:3000`

### Issue: Container unhealthy
**Fix**: Check environment variables are set correctly
```bash
docker logs <cognee-container-name>
```

## Quick Reference

**Your Endpoints:**
- Main API: `https://cognee.v1su4.com`
- Health: `https://cognee.v1su4.com/health`
- Status: `https://cognee.v1su4.com/status`
- Docs: `https://cognee.v1su4.com/docs`

**Key URLs:**
- Neo4j Browser: `https://neo4j-cognee.v1su4.com` (if exposed)
- Qdrant Dashboard: `https://qdrant-cognee.v1su4.com` (if exposed)

## Why This Works

1. **Pre-built image** = No build complexity
2. **Direct image deployment** = No docker-compose SERVICE_FQDN issues
3. **UI domain configuration** = Clear and simple
4. **Standard ports** = No conflicts with Coolify port 8000

## Next Steps

Once you confirm this works:
1. ✅ Keep using Docker images for production
2. ✅ Set up CI/CD if you need automatic updates
3. ✅ Add monitoring/alerts if needed

**You now have a working Cognee API for your Goose MCP server! 🚀**

---

**Time to deploy**: ~5 minutes  
**Complexity**: Low  
**Success rate**: High  
**Hassle**: Minimal