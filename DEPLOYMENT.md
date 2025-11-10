# Cognee Deployment Guide for Coolify

This guide walks you through deploying Cognee on Coolify step-by-step.

## Prerequisites

1. **Coolify server** running (install with: `curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash`)
2. **Domain name** (optional, but recommended for production)
3. **API keys** for your chosen LLM provider (OpenAI, Anthropic, etc.)

## Step-by-Step Deployment

### Step 1: Prepare Your Environment File

1. Copy `env.example` to `.env`:
   ```bash
   cp env.example .env
   ```

2. Edit `.env` with your configuration:
   ```bash
   nano .env
   ```

3. **Required changes:**
   - Set `POSTGRES_PASSWORD` to a strong password
   - Set `NEO4J_PASSWORD` to a strong password
   - Set `LLM_API_KEY` to your OpenAI API key
   - Set `EMBEDDING_API_KEY` to your OpenAI API key

### Step 2: Deploy via Coolify Dashboard

#### Method A: Docker Compose Deployment

1. **Login to Coolify** (usually at `http://your-server-ip:8000`)

2. **Create New Resource:**
   - Click "Add New Resource"
   - Select "Docker Compose Empty"

3. **Configure Docker Compose:**
   - Copy the entire contents of `docker-compose.yaml`
   - Paste into the Coolify editor

4. **Add Environment Variables:**
   - Go to "Environment Variables" tab
   - Add each variable from your `.env` file:
     - `POSTGRES_PASSWORD`
     - `NEO4J_PASSWORD`
     - `LLM_API_KEY`
     - `EMBEDDING_API_KEY`
     - (and any other custom variables)

5. **Configure Domains (Optional):**
   - Go to "Domains" tab
   - Add your domain for the Cognee API
   - Coolify will automatically generate SSL certificates

6. **Deploy:**
   - Click "Deploy" button
   - Monitor the deployment logs
   - Wait for all services to be healthy

#### Method B: Git Repository Deployment

1. **Push to GitHub:**
   ```bash
   git init
   git add .
   git commit -m "Initial Cognee deployment"
   git remote add origin <your-repo-url>
   git push -u origin main
   ```

2. **In Coolify:**
   - Click "Add New Resource"
   - Select "Git Repository"
   - Connect your GitHub/GitLab account
   - Select your repository
   - Choose branch (usually `main`)

3. **Configure Build:**
   - Coolify will auto-detect `docker-compose.yaml`
   - Go to "Environment Variables" and add your variables
   - Configure domain if needed

4. **Deploy:**
   - Click "Deploy"
   - Coolify will clone, build, and deploy

### Step 3: Verify Deployment

1. **Check Service Health:**
   ```bash
   curl http://your-domain/health
   # or
   curl http://your-server-ip:8000/health
   ```

   Expected response:
   ```json
   {"status": "healthy", "service": "cognee-api"}
   ```

2. **Check Status:**
   ```bash
   curl http://your-domain/status
   ```

3. **Access API Documentation:**
   - Open browser: `http://your-domain/docs`
   - You'll see the interactive Swagger UI

4. **Access Service Dashboards:**
   - **Cognee API**: `http://your-domain` (or port 8000)
   - **Neo4j Browser**: `http://your-domain:7474`
   - **Qdrant Dashboard**: `http://your-domain:6333/dashboard`

### Step 4: Test the API

```bash
# Add some data
curl -X POST http://your-domain/add \
  -H "Content-Type: application/json" \
  -d '{
    "data": "Artificial Intelligence is transforming how we build software.",
    "dataset_name": "test-dataset"
  }'

# Cognify (build knowledge graph)
curl -X POST http://your-domain/cognify \
  -H "Content-Type: application/json" \
  -d '{"dataset_name": "test-dataset"}'

# Search
curl -X POST http://your-domain/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What is AI?",
    "mode": "default"
  }'
```

## Goose Integration

### Step 1: Install Cognee MCP Server

On your **local machine** (where Goose runs):

```bash
# Clone the Cognee repository
git clone https://github.com/topoteretes/cognee
cd cognee/cognee-mcp

# Install dependencies using uv (recommended)
# First install uv if you haven't:
curl -LsSf https://astral.sh/uv/install.sh | sh

# Then install dependencies
uv sync --dev --all-extras --reinstall

# On Linux, you may need additional dependencies
sudo apt install -y libpq-dev python3-dev
```

### Step 2: Configure Goose

Create or edit `~/.config/goose/profiles.yaml`:

```yaml
default:
  provider: openai
  processor: gpt-4
  accelerator: gpt-4
  moderator: passive
  
  toolkits:
    - name: developer
    - name: github
  
  mcp_servers:
    cognee:
      command: uv
      args:
        - --directory
        - /absolute/path/to/cognee-mcp  # Update this path!
        - run
        - python
        - src/server.py
      env:
        COGNEE_API_URL: http://your-domain:8000  # Your Coolify deployment URL
        LLM_API_KEY: ${LLM_API_KEY}
        EMBEDDING_API_KEY: ${EMBEDDING_API_KEY}
```

**Important:** Replace:
- `/absolute/path/to/cognee-mcp` with actual path
- `http://your-domain:8000` with your Coolify deployment URL

### Step 3: Start Using Goose with Cognee

```bash
# Start Goose
goose session start

# Test Cognee integration
# In the Goose prompt, try:
# "Add this file to Cognee memory" (when viewing a code file)
# "Search Cognee for authentication patterns"
# "Build a knowledge graph from my project files"
```

## Troubleshooting

### Service Won't Start

```bash
# SSH into your Coolify server
ssh user@your-server

# Check Docker logs
cd /data/coolify/applications/<your-app-id>
docker-compose logs cognee
docker-compose logs neo4j
docker-compose logs postgres
```

### Connection Issues

1. **Check firewall rules:**
   ```bash
   sudo ufw status
   # Ensure ports 8000, 7474, 7687, 6333 are open if needed
   ```

2. **Verify environment variables:**
   - In Coolify dashboard, check "Environment Variables" tab
   - Ensure all required variables are set

3. **Wait for initialization:**
   - Neo4j can take 30-60 seconds to fully start
   - PostgreSQL needs time to initialize
   - Check logs for "ready to accept connections"

### Memory Issues

If you see out-of-memory errors:

1. **Reduce Neo4j heap size** in environment variables:
   ```
   NEO4J_HEAP_SIZE=1G
   ```

2. **Increase server resources** via your hosting provider

### API Errors

1. **Check LLM API key is valid:**
   ```bash
   curl -X POST http://your-domain/status
   ```

2. **Verify all services are healthy:**
   ```bash
   docker-compose ps
   ```

3. **Review application logs:**
   ```bash
   docker-compose logs -f cognee
   ```

## Maintenance

### Backup Your Data

```bash
# PostgreSQL backup
docker-compose exec postgres pg_dump -U cognee cognee > backup-$(date +%Y%m%d).sql

# Neo4j backup
docker-compose exec neo4j neo4j-admin dump --to=/tmp/backup.dump
docker cp cognee-neo4j:/tmp/backup.dump ./neo4j-backup-$(date +%Y%m%d).dump
```

### Update Deployment

In Coolify:
1. Go to your application
2. Click "Redeploy"
3. Coolify will pull latest changes and rebuild

Or manually:
```bash
git pull
docker-compose pull
docker-compose up -d
```

### Monitor Resources

In Coolify dashboard:
- View CPU, memory, and disk usage
- Set up alerts for resource thresholds
- Monitor container logs

## Security Best Practices

1. **Use strong passwords** for all services
2. **Enable HTTPS** via Coolify's built-in SSL
3. **Restrict database ports** (don't expose publicly)
4. **Regular backups** automated via cron
5. **Update regularly** to get security patches
6. **Monitor logs** for suspicious activity
7. **Use API authentication** (implement in main.py if needed)

## Support Resources

- [Coolify Documentation](https://coolify.io/docs)
- [Cognee Documentation](https://docs.cognee.ai/)
- [Cognee GitHub](https://github.com/topoteretes/cognee)
- [Goose Documentation](https://block.github.io/goose/)

