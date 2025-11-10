# Cognee Self-Hosted Deployment

Self-hosted Cognee deployment with Docker and Coolify support for integration with Goose AI agent.

## 🚀 Features

- **Complete Docker setup** with PostgreSQL, Neo4j, and Qdrant
- **Coolify-ready** deployment configuration
- **RESTful API** for all Cognee operations
- **Health checks** and monitoring
- **Goose integration** ready

## 📋 Prerequisites

- Docker and Docker Compose installed
- (Optional) Coolify installed for managed deployment
- OpenAI API key (or other LLM provider)
- At least 4GB RAM available
- 10GB disk space

## 🛠️ Quick Start

### 1. Clone and Configure

```bash
# Navigate to the project directory
cd cognee

# Copy environment template
cp .env.example .env

# Edit .env with your configuration
nano .env  # or your preferred editor
```

**Required environment variables:**
- `LLM_API_KEY`: Your OpenAI API key
- `EMBEDDING_API_KEY`: Your OpenAI API key (can be same as LLM_API_KEY)
- `POSTGRES_PASSWORD`: Secure password for PostgreSQL
- `NEO4J_PASSWORD`: Secure password for Neo4j

### 2. Deploy with Docker Compose

```bash
# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f cognee
```

### 3. Verify Deployment

```bash
# Check health endpoint
curl http://localhost:8000/health

# Check status
curl http://localhost:8000/status
```

Access the services:
- **Cognee API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Neo4j Browser**: http://localhost:7474
- **Qdrant Dashboard**: http://localhost:6333/dashboard

## 🎯 Coolify Deployment

### Option 1: Via Coolify Dashboard

1. **Login to Coolify** dashboard
2. **Add New Resource** → Select "Docker Compose Empty"
3. **Copy docker-compose.yaml** contents into the editor
4. **Add Environment Variables**:
   - Go to "Environment Variables" tab
   - Add all variables from `.env.example`
   - Set your API keys and passwords
5. **Deploy** - Click the deploy button

### Option 2: Via Git Integration

1. **Push to GitHub**:
   ```bash
   git init
   git add .
   git commit -m "Initial Cognee deployment"
   git remote add origin <your-repo-url>
   git push -u origin main
   ```

2. **In Coolify**:
   - Add New Resource → Git Repository
   - Connect your repository
   - Coolify will auto-detect docker-compose.yaml
   - Add environment variables
   - Deploy

## 🤖 Goose Integration

### Install Cognee Extension for Goose

```bash
# Clone Cognee MCP repository
git clone https://github.com/topoteretes/cognee
cd cognee/cognee-mcp

# Install dependencies (using uv)
uv sync --dev --all-extras --reinstall

# On Linux, install additional dependencies
sudo apt install -y libpq-dev python3-dev
```

### Configure Goose

Create or update your Goose configuration (`~/.config/goose/profiles.yaml`):

```yaml
default:
  provider: openai
  processor: gpt-4
  accelerator: gpt-4
  moderator: passive
  toolkits:
    - name: developer
    - name: github
  
  # Add Cognee MCP server
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
        COGNEE_API_URL: http://localhost:8000
        LLM_API_KEY: ${LLM_API_KEY}
        EMBEDDING_API_KEY: ${EMBEDDING_API_KEY}
```

### Start Using Goose with Cognee

```bash
# Configure Goose
goose configure

# Start Goose session
goose session start

# Test Cognee integration
# In Goose, you can now:
# - Add documents to Cognee memory
# - Search knowledge graphs
# - Build AI memory from your codebase
```

## 📚 API Endpoints

### Core Operations

**Add Data**
```bash
curl -X POST http://localhost:8000/add \
  -H "Content-Type: application/json" \
  -d '{"data": "Your text content here", "dataset_name": "my-dataset"}'
```

**Cognify (Build Knowledge Graph)**
```bash
curl -X POST http://localhost:8000/cognify \
  -H "Content-Type: application/json" \
  -d '{"dataset_name": "my-dataset"}'
```

**Search**
```bash
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "What is AI memory?", "mode": "default"}'
```

**Reset (Clear All Data)**
```bash
curl -X DELETE http://localhost:8000/reset
```

**Get Status**
```bash
curl http://localhost:8000/status
```

## 🔧 Configuration

### LLM Providers

Cognee supports multiple LLM providers. Update `.env`:

**OpenAI (Default)**
```env
LLM_PROVIDER=openai
LLM_API_KEY=sk-...
LLM_MODEL=gpt-4
```

**Anthropic Claude**
```env
LLM_PROVIDER=anthropic
ANTHROPIC_API_KEY=sk-ant-...
LLM_MODEL=claude-3-opus-20240229
```

**Azure OpenAI**
```env
LLM_PROVIDER=azure
AZURE_OPENAI_ENDPOINT=https://your-endpoint.openai.azure.com/
AZURE_OPENAI_API_KEY=...
AZURE_OPENAI_API_VERSION=2023-05-15
```

**Ollama (Local)**
```env
LLM_PROVIDER=ollama
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama2
```

### Vector Stores

**Qdrant (Default - Included)**
```env
VECTOR_DB_PROVIDER=qdrant
QDRANT_URL=http://qdrant:6333
```

**Pinecone**
```env
VECTOR_DB_PROVIDER=pinecone
PINECONE_API_KEY=...
PINECONE_ENVIRONMENT=...
```

### Graph Databases

**Neo4j (Default - Included)**
```env
GRAPH_DB_PROVIDER=neo4j
NEO4J_URI=bolt://neo4j:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=...
```

## 🔍 Monitoring

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f cognee
docker-compose logs -f neo4j
docker-compose logs -f postgres
```

### Check Resource Usage

```bash
docker stats
```

### Neo4j Browser

Access Neo4j Browser at http://localhost:7474 to:
- Visualize knowledge graphs
- Run Cypher queries
- Monitor graph database

## 🛠️ Maintenance

### Backup Data

```bash
# Backup PostgreSQL
docker-compose exec postgres pg_dump -U cognee cognee > backup.sql

# Backup Neo4j
docker-compose exec neo4j neo4j-admin dump --to=/tmp/neo4j-backup.dump
docker cp cognee-neo4j:/tmp/neo4j-backup.dump ./neo4j-backup.dump
```

### Update Services

```bash
# Pull latest images
docker-compose pull

# Restart services
docker-compose up -d
```

### Reset Everything

```bash
# Stop and remove all containers and volumes
docker-compose down -v

# Start fresh
docker-compose up -d
```

## 🐛 Troubleshooting

### Service won't start

```bash
# Check logs
docker-compose logs cognee

# Verify environment variables
docker-compose config

# Check port conflicts
netstat -tuln | grep -E '8000|7474|7687|6333|5432'
```

### Cannot connect to Cognee API

1. Verify all services are healthy:
   ```bash
   docker-compose ps
   ```

2. Wait for initialization (especially Neo4j):
   ```bash
   docker-compose logs -f neo4j
   ```

3. Check health endpoint:
   ```bash
   curl http://localhost:8000/health
   ```

### Out of memory errors

Increase Docker memory limits or reduce Neo4j heap size in `.env`:
```env
NEO4J_HEAP_SIZE=1G  # Reduce from 2G
```

## 📖 Documentation

- [Cognee Documentation](https://docs.cognee.ai/)
- [Goose Documentation](https://block.github.io/goose/)
- [Coolify Documentation](https://coolify.io/docs)

## 🔐 Security Considerations

For production deployments:

1. **Change default passwords** in `.env`
2. **Use strong passwords** for all services
3. **Configure CORS** properly in `main.py`
4. **Use HTTPS** with reverse proxy (nginx/traefik)
5. **Restrict network access** to databases
6. **Enable authentication** for Neo4j and Qdrant
7. **Regular backups** of all data
8. **Monitor logs** for suspicious activity

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## 📄 License

This deployment configuration is provided as-is. Check Cognee's license for the core software.

## 🆘 Support

- [Cognee GitHub](https://github.com/topoteretes/cognee)
- [Cognee Discord](https://discord.gg/cognee)
- [Goose GitHub](https://github.com/block/goose)

