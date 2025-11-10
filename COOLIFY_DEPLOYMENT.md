# Deploying Cognee to Coolify on cognee.v1su4.com

This guide covers deploying your Cognee instance to `cognee.v1su4.com` using Coolify.

## 🌐 Domain Configuration

**Your Setup:**
- **Domain:** `cognee.v1su4.com`
- **Base Domain:** `v1su4.com`
- **SSL:** Automatic via Let's Encrypt (handled by Coolify)
- **Protocol:** HTTPS (automatic)

## 📋 Prerequisites

1. ✅ Coolify installed on your server
2. ✅ DNS A record for `cognee.v1su4.com` pointing to your server IP
3. ✅ GitHub repository (or direct deployment)
4. ✅ API keys ready (OpenAI, etc.)

## 🚀 Deployment Steps

### Step 1: Verify DNS

First, ensure your DNS is properly configured:

```bash
# Check DNS resolution
nslookup cognee.v1su4.com

# Or using dig
dig cognee.v1su4.com
```

**Expected result:** Should resolve to your Coolify server's IP address.

### Step 2: Push to GitHub (If Using Git Method)

```bash
# Initialize git if not already done
git init

# Add all files
git add .

# Commit
git commit -m "Initial Cognee deployment for cognee.v1su4.com"

# Push to your repository
git remote add origin https://github.com/gordo-v1su4/cognee.git
git push -u origin main
```

### Step 3: Create New Resource in Coolify

1. **Login to Coolify Dashboard**
   - Usually at: `https://coolify.v1su4.com` or your Coolify URL

2. **Add New Resource**
   - Click "**+ Add**" or "**New Resource**"
   - Choose deployment method:
     - **Option A:** Docker Compose (paste the compose file)
     - **Option B:** Git Repository (connect your repo)

3. **Configure Project**
   - **Name:** `cognee`
   - **Type:** Docker Compose
   - **Domain:** `cognee.v1su4.com`

### Step 4: Configure Environment Variables

In the Coolify dashboard, go to **Environment Variables** and add:

#### **Required Variables:**

```bash
# LLM Configuration
LLM_API_KEY=sk-your-openai-api-key-here
LLM_PROVIDER=openai
LLM_MODEL=gpt-4

# Embedding Configuration
EMBEDDING_API_KEY=sk-your-openai-api-key-here
EMBEDDING_PROVIDER=openai
EMBEDDING_MODEL=text-embedding-3-small

# Database Passwords (CHANGE THESE!)
POSTGRES_PASSWORD=your-super-secure-postgres-password
NEO4J_PASSWORD=your-super-secure-neo4j-password

# Domain Configuration
COGNEE_DOMAIN=cognee.v1su4.com
COGNEE_URL=https://cognee.v1su4.com
```

#### **Optional Variables:**

```bash
# Database Configuration
POSTGRES_DB=cognee
POSTGRES_USER=cognee
NEO4J_USER=neo4j

# Vector Store
VECTOR_DB_PROVIDER=qdrant
GRAPH_DB_PROVIDER=neo4j

# Application
COGNEE_PORT=8000
COGNEE_ENV=production
LOG_LEVEL=INFO
NEO4J_HEAP_SIZE=2G
```

### Step 5: Configure Domain & SSL

1. **Set Domain:**
   - Go to **Domains** tab in Coolify
   - Add: `cognee.v1su4.com`
   - Coolify will automatically request SSL certificate from Let's Encrypt

2. **Verify SSL:**
   - Coolify handles SSL automatically
   - Wait ~2 minutes for certificate to be issued
   - You'll see a green checkmark when ready

### Step 6: Deploy!

1. Click the **"Deploy"** button
2. Monitor the deployment logs
3. Wait for all services to be healthy (2-5 minutes)

### Step 7: Verify Deployment

Once deployed, test your instance:

```bash
# Check health
curl https://cognee.v1su4.com/health

# Expected response:
# {"status": "healthy", "service": "cognee-api"}

# Check status
curl https://cognee.v1su4.com/status
```

**Access in browser:**
- **API Docs:** https://cognee.v1su4.com/docs
- **Health Check:** https://cognee.v1su4.com/health
- **Status:** https://cognee.v1su4.com/status

## 🔧 Accessing Internal Services

Since you're hosting on `v1su4.com`, you might want to expose other services:

### Neo4j Browser (Optional)

Add a subdomain for Neo4j:
- **Domain:** `neo4j-cognee.v1su4.com`
- **Port:** 7474

In Coolify, add port mapping:
```yaml
neo4j:
  labels:
    - traefik.enable=true
    - traefik.http.routers.neo4j-cognee.rule=Host(`neo4j-cognee.v1su4.com`)
    - traefik.http.services.neo4j-cognee.loadbalancer.server.port=7474
```

### Qdrant Dashboard (Optional)

- **Domain:** `qdrant-cognee.v1su4.com`
- **Port:** 6333

## 🤖 Update Goose Configuration

Once deployed, update your Goose configuration to use the production URL:

**Edit:** `~/.config/goose/profiles.yaml`

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
      COGNEE_API_URL: https://cognee.v1su4.com  # ← Your production URL
      LLM_API_KEY: ${LLM_API_KEY}
      EMBEDDING_API_KEY: ${EMBEDDING_API_KEY}
```

Now Goose will connect to your production instance at `cognee.v1su4.com`!

## 📊 Monitoring & Maintenance

### View Logs

In Coolify dashboard:
1. Go to your Cognee application
2. Click on "Logs" tab
3. Select service (cognee, postgres, neo4j, qdrant)
4. View real-time logs

### Check Resource Usage

Coolify shows:
- CPU usage
- Memory usage
- Network traffic
- Disk usage

### Update Deployment

To update your deployment:

1. **Push changes to Git:**
   ```bash
   git add .
   git commit -m "Update configuration"
   git push
   ```

2. **In Coolify:**
   - Click "Redeploy" button
   - Or enable auto-deployment on git push

## 🔐 Security Best Practices

### 1. Firewall Configuration

Ensure only necessary ports are open:

```bash
# Allow HTTPS (Traefik/Coolify handles this)
sudo ufw allow 443/tcp

# Allow SSH
sudo ufw allow 22/tcp

# Block direct access to service ports
# (Let Traefik handle routing)
```

### 2. Strong Passwords

Update your `.env` with strong passwords:

```bash
# Generate strong passwords
openssl rand -base64 32
```

### 3. API Key Security

- Store API keys securely in Coolify's environment variables
- Never commit API keys to Git
- Rotate keys periodically

### 4. Regular Backups

Set up automated backups in Coolify:
1. Go to Settings → Backups
2. Configure backup schedule
3. Choose backup destination (S3, local, etc.)

## 🧪 Testing Your Deployment

### Quick API Test

```bash
# Add data
curl -X POST https://cognee.v1su4.com/add \
  -H "Content-Type: application/json" \
  -d '{
    "data": "Welcome to Cognee on v1su4.com!",
    "dataset_name": "welcome"
  }'

# Cognify
curl -X POST https://cognee.v1su4.com/cognify \
  -H "Content-Type: application/json" \
  -d '{"dataset_name": "welcome"}'

# Search
curl -X POST https://cognee.v1su4.com/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Tell me about this deployment",
    "mode": "default"
  }'
```

### Test with Goose

```bash
# Start Goose session
goose session start

# In Goose, try:
# "Add this message to Cognee: My v1su4.com deployment is working!"
# "Search Cognee for deployment information"
```

## 🐛 Troubleshooting

### Service Won't Start

```bash
# Check logs in Coolify dashboard
# Or SSH into server and check:
docker ps
docker logs <container-id>
```

### SSL Certificate Issues

If SSL isn't working:
1. Verify DNS points to correct IP
2. Wait 2-5 minutes for certificate issuance
3. Check Coolify logs for certificate errors
4. Ensure port 80 and 443 are accessible

### Can't Access the API

1. **Check DNS:**
   ```bash
   nslookup cognee.v1su4.com
   ```

2. **Check if services are running:**
   - View in Coolify dashboard
   - All containers should show "running"

3. **Check health endpoint:**
   ```bash
   curl https://cognee.v1su4.com/health
   ```

### Database Connection Issues

If Cognee can't connect to databases:
1. Check environment variables are set correctly
2. Verify network configuration in docker-compose.yaml
3. Check service logs for connection errors

## 🔄 Updating Your Deployment

### Method 1: Git Push (Automatic)

If you've enabled auto-deploy in Coolify:

```bash
git add .
git commit -m "Update"
git push
# Coolify automatically rebuilds and deploys
```

### Method 2: Manual Redeploy

In Coolify dashboard:
1. Go to your application
2. Click "Redeploy"
3. Wait for build and deployment

### Method 3: Update Environment Variables

To change configuration:
1. Update environment variables in Coolify
2. Click "Restart" (no rebuild needed)

## 📈 Scaling & Performance

### Increase Resources

If you need more power:

1. **Adjust Neo4j Memory:**
   ```bash
   NEO4J_HEAP_SIZE=4G  # Increase from 2G
   ```

2. **Add More CPU/RAM:**
   - Configure in your hosting provider
   - Restart containers

3. **Database Optimization:**
   - Tune PostgreSQL settings
   - Optimize Neo4j queries
   - Configure Qdrant collection settings

## 🌍 Multiple Environments

You might want staging + production:

**Production:** `cognee.v1su4.com`
**Staging:** `cognee-staging.v1su4.com`

Deploy two instances in Coolify with different domains and configurations.

## 📞 Support Resources

- **Coolify Docs:** https://coolify.io/docs
- **Cognee Docs:** https://docs.cognee.ai/
- **Your Domain:** https://cognee.v1su4.com
- **API Docs:** https://cognee.v1su4.com/docs

## ✅ Deployment Checklist

- [ ] DNS configured for `cognee.v1su4.com`
- [ ] Repository pushed to GitHub (if using Git method)
- [ ] Coolify project created
- [ ] Environment variables configured
- [ ] Domain added in Coolify
- [ ] SSL certificate issued (automatic)
- [ ] Deployment successful
- [ ] Health check passing: `https://cognee.v1su4.com/health`
- [ ] API accessible: `https://cognee.v1su4.com/docs`
- [ ] Goose configured with production URL
- [ ] Backups configured
- [ ] Monitoring set up

## 🎉 You're Live!

Your Cognee instance is now running at:

**🌐 https://cognee.v1su4.com**

- ✅ Automatic HTTPS
- ✅ Let's Encrypt SSL
- ✅ Professional domain
- ✅ Production ready
- ✅ Goose compatible

Happy building! 🚀

