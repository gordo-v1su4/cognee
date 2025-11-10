# 🚀 Quick Deploy to cognee.v1su4.com

**Your Cognee instance will be available at:** `https://cognee.v1su4.com`

## ⚡ Quick Deploy (5 Steps)

### 1. Configure DNS ✅
Add A record in your DNS provider:
```
Type: A
Name: cognee
Value: [Your Coolify Server IP]
TTL: 300 (or auto)
```

**Verify:**
```bash
nslookup cognee.v1su4.com
# Should return your server IP
```

### 2. Prepare Environment File ✅
```bash
cp env.example .env
nano .env
```

**Essential settings:**
```env
LLM_API_KEY=sk-your-key-here
EMBEDDING_API_KEY=sk-your-key-here
POSTGRES_PASSWORD=secure-password-123
NEO4J_PASSWORD=another-secure-password-456

COGNEE_DOMAIN=cognee.v1su4.com
COGNEE_URL=https://cognee.v1su4.com
```

### 3. Push to GitHub ✅
```bash
git add .
git commit -m "Deploy Cognee to cognee.v1su4.com"
git push origin main
```

### 4. Deploy in Coolify ✅

**In Coolify Dashboard:**
1. Click **"+ Add"** → New Resource
2. Choose **"Git Repository"** or **"Docker Compose"**
3. If Git: Select your repo
4. If Docker Compose: Paste `docker-compose.yaml` contents
5. Set **Domain:** `cognee.v1su4.com`
6. Add **Environment Variables** from your `.env`
7. Click **"Deploy"** 🚀

**Coolify will automatically:**
- Build your containers
- Request SSL certificate from Let's Encrypt
- Configure Traefik routing
- Start all services

### 5. Test Your Deployment ✅

Wait 2-5 minutes, then:

```bash
# Health check
curl https://cognee.v1su4.com/health

# Expected: {"status": "healthy", "service": "cognee-api"}
```

**Open in browser:**
- https://cognee.v1su4.com/docs

## 🎯 Your URLs

| Service | URL | Description |
|---------|-----|-------------|
| **API** | https://cognee.v1su4.com | Main API endpoint |
| **Docs** | https://cognee.v1su4.com/docs | Interactive API documentation |
| **Health** | https://cognee.v1su4.com/health | Health check endpoint |
| **Status** | https://cognee.v1su4.com/status | System status |

## 🤖 Configure Goose

Update `~/.config/goose/profiles.yaml`:

```yaml
mcp_servers:
  cognee:
    command: uv
    args:
      - --directory
      - /absolute/path/to/cognee-mcp
      - run
      - python
      - src/server.py
    env:
      COGNEE_API_URL: https://cognee.v1su4.com  # ← Your production URL!
      LLM_API_KEY: ${LLM_API_KEY}
      EMBEDDING_API_KEY: ${EMBEDDING_API_KEY}
```

Then:
```bash
goose session start
# Now Goose connects to your v1su4.com deployment!
```

## 🧪 Quick API Test

```bash
# Add data
curl -X POST https://cognee.v1su4.com/add \
  -H "Content-Type: application/json" \
  -d '{"data": "Cognee is live on v1su4.com!", "dataset_name": "welcome"}'

# Cognify
curl -X POST https://cognee.v1su4.com/cognify \
  -H "Content-Type: application/json" \
  -d '{"dataset_name": "welcome"}'

# Search
curl -X POST https://cognee.v1su4.com/search \
  -H "Content-Type: application/json" \
  -d '{"query": "Tell me about this deployment", "mode": "default"}'
```

## 🔧 Troubleshooting

### DNS Not Resolving
```bash
# Check DNS propagation
nslookup cognee.v1su4.com

# If not working, wait 5-10 minutes for DNS propagation
# Or flush DNS cache:
# Windows: ipconfig /flushdns
# Mac: sudo dscacheutil -flushcache
# Linux: sudo systemd-resolve --flush-caches
```

### SSL Certificate Not Issued
- Wait 2-5 minutes for Let's Encrypt
- Verify DNS is pointing to correct IP
- Check Coolify logs for certificate errors
- Ensure ports 80 and 443 are open

### Services Not Starting
1. Check Coolify deployment logs
2. Verify environment variables are set
3. Check resource usage (CPU/RAM)
4. SSH to server and check: `docker ps`

### Can't Access API
1. Verify deployment completed in Coolify
2. Check health: `curl https://cognee.v1su4.com/health`
3. View logs in Coolify dashboard
4. Ensure firewall allows HTTPS (port 443)

## 📊 Monitor Your Deployment

**In Coolify Dashboard:**
- View real-time logs
- Monitor CPU, RAM, disk usage
- Check deployment history
- Configure alerts
- Set up automated backups

## 🔄 Update Your Deployment

### Option 1: Git Push (Auto-deploy)
```bash
# Make changes
git add .
git commit -m "Update configuration"
git push

# If auto-deploy enabled, Coolify rebuilds automatically
```

### Option 2: Manual Redeploy
In Coolify → Click **"Redeploy"** button

### Option 3: Update Env Vars Only
In Coolify → Environment Variables → Update → **"Restart"**

## 🌟 Optional: Additional Subdomains

Want to expose Neo4j or Qdrant dashboards?

### Neo4j Browser
**Domain:** `neo4j.cognee.v1su4.com` or `cognee-neo4j.v1su4.com`

Add to `docker-compose.yaml`:
```yaml
neo4j:
  labels:
    - traefik.enable=true
    - traefik.http.routers.neo4j.rule=Host(`neo4j.cognee.v1su4.com`)
    - traefik.http.routers.neo4j.entrypoints=websecure
    - traefik.http.routers.neo4j.tls.certresolver=letsencrypt
    - traefik.http.services.neo4j.loadbalancer.server.port=7474
```

### Qdrant Dashboard
**Domain:** `qdrant.cognee.v1su4.com`

Add to `docker-compose.yaml`:
```yaml
qdrant:
  labels:
    - traefik.enable=true
    - traefik.http.routers.qdrant.rule=Host(`qdrant.cognee.v1su4.com`)
    - traefik.http.routers.qdrant.entrypoints=websecure
    - traefik.http.routers.qdrant.tls.certresolver=letsencrypt
    - traefik.http.services.qdrant.loadbalancer.server.port=6333
```

## ✅ Deployment Checklist

- [ ] DNS configured (`cognee.v1su4.com` → server IP)
- [ ] `.env` file configured with API keys
- [ ] Code pushed to GitHub
- [ ] Coolify project created
- [ ] Domain set in Coolify
- [ ] Environment variables added in Coolify
- [ ] Deployment started
- [ ] SSL certificate issued (automatic)
- [ ] Health check passing
- [ ] API docs accessible
- [ ] Goose configured with production URL
- [ ] Test queries working

## 🎉 You're Live!

Your Cognee instance is now running at:

### 🌐 **https://cognee.v1su4.com**

**Features:**
- ✅ Production-ready deployment
- ✅ Automatic HTTPS with Let's Encrypt
- ✅ Professional domain on v1su4.com
- ✅ Coolify managed (easy updates)
- ✅ Integrated with Goose AI
- ✅ Multi-database architecture
- ✅ RESTful API with docs
- ✅ Knowledge graph capabilities

---

**Need More Help?**
- 📖 Full guide: [COOLIFY_DEPLOYMENT.md](COOLIFY_DEPLOYMENT.md)
- 🐛 Troubleshooting: See Coolify logs
- 💬 Community: Cognee Discord

**Happy building on v1su4.com! 🚀**

