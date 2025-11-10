# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a self-hosted Cognee deployment project that provides a RESTful API for AI memory and knowledge graph management. It's designed for Coolify deployment and Goose AI agent integration.

**Tech Stack:**
- **Backend**: FastAPI (Python 3.11+) with async/await patterns
- **Databases**: PostgreSQL (metadata), Neo4j (knowledge graphs), Qdrant (vector embeddings)
- **Deployment**: Docker Compose, Coolify-ready
- **LLM Integration**: Supports OpenAI, Anthropic, Azure OpenAI, Ollama

## Core Architecture

### Service Architecture
The system runs as a multi-container Docker deployment with 4 main services:

1. **Cognee API** (`main.py`): FastAPI application that orchestrates all operations
   - Entry point for all API calls
   - Manages lifespan (initialization/cleanup) via async context manager
   - Uses Cognee library for core knowledge graph operations
   - Exposes REST endpoints: `/add`, `/cognify`, `/search`, `/reset`, `/status`, `/health`

2. **PostgreSQL**: Stores relational metadata for Cognee
   - Database: `cognee`
   - Accessed via SQLAlchemy + Alembic for migrations

3. **Neo4j**: Graph database for knowledge graph storage and traversal
   - Runs with APOC plugin for advanced graph operations
   - Accessible via Bolt protocol (port 7687) and HTTP (port 7474)

4. **Qdrant**: Vector store for embeddings and similarity search
   - REST API on port 6333
   - Used for semantic search before graph traversal

### Key Workflow
1. **Add**: Data ingestion via `/add` endpoint → stores in datasets
2. **Cognify**: Processes data via `/cognify` → builds knowledge graphs in Neo4j + embeddings in Qdrant
3. **Search**: Query via `/search` → combines vector similarity (Qdrant) + graph traversal (Neo4j)
4. **Reset**: Clears all data via `/reset` (destructive operation)

## Common Development Commands

### Local Development

```powershell
# Setup
cp env.example .env
# Edit .env with your API keys and passwords

# Start all services (Windows PowerShell)
docker-compose up -d

# View logs
docker-compose logs -f cognee
docker-compose logs -f          # All services

# Check service status
docker-compose ps
docker stats

# Health checks
curl http://localhost:8000/health
curl http://localhost:8000/status

# Run health check script (requires WSL or Git Bash on Windows)
bash healthcheck.sh

# Stop services
docker-compose down

# Stop and remove all data (volumes)
docker-compose down -v
```

### Testing API Endpoints

```powershell
# Add data
curl -X POST http://localhost:8000/add `
  -H "Content-Type: application/json" `
  -d '{"data": "Your text content", "dataset_name": "test-dataset"}'

# Cognify (build knowledge graph)
curl -X POST http://localhost:8000/cognify `
  -H "Content-Type: application/json" `
  -d '{"dataset_name": "test-dataset"}'

# Search
curl -X POST http://localhost:8000/search `
  -H "Content-Type: application/json" `
  -d '{"query": "What is AI memory?", "mode": "default"}'

# Reset (clears all data)
curl -X DELETE http://localhost:8000/reset

# Get status
curl http://localhost:8000/status
```

### Database Access

```powershell
# Neo4j Browser
# Open http://localhost:7474 in browser
# Username: neo4j
# Password: (from .env NEO4J_PASSWORD)

# Qdrant Dashboard
# Open http://localhost:6333/dashboard in browser

# PostgreSQL shell
docker-compose exec postgres psql -U cognee -d cognee

# Backup PostgreSQL
docker-compose exec postgres pg_dump -U cognee cognee > backup.sql

# Backup Neo4j
docker-compose exec neo4j neo4j-admin dump --to=/tmp/neo4j-backup.dump
docker cp cognee-neo4j:/tmp/neo4j-backup.dump ./neo4j-backup.dump
```

### Maintenance

```powershell
# Update images
docker-compose pull
docker-compose up -d

# Restart specific service
docker-compose restart cognee
docker-compose restart neo4j

# Validate configuration
docker-compose config

# Check resource usage
docker stats

# Clean up unused Docker resources
docker system prune -a
```

## Configuration

### Environment Variables (.env)

**Required:**
- `LLM_API_KEY`: OpenAI/LLM API key (never commit!)
- `EMBEDDING_API_KEY`: Embedding API key (often same as LLM_API_KEY)
- `POSTGRES_PASSWORD`: Secure password for PostgreSQL
- `NEO4J_PASSWORD`: Secure password for Neo4j

**LLM Provider Options:**
- `LLM_PROVIDER`: `openai` (default), `anthropic`, `azure`, `ollama`
- `LLM_MODEL`: Model name (e.g., `gpt-4`, `claude-3-opus-20240229`)

**Database Providers:**
- `VECTOR_DB_PROVIDER`: `qdrant` (default, included), `pinecone`, `weaviate`
- `GRAPH_DB_PROVIDER`: `neo4j` (default, included), `networkx`

**Application:**
- `COGNEE_PORT`: API port (default: 8000)
- `COGNEE_ENV`: `production` or `development`
- `LOG_LEVEL`: `INFO`, `DEBUG`, `WARNING`, `ERROR`

### Coolify Deployment

This repository is Coolify-ready with:
- **docker-compose.yaml** includes Coolify labels and Traefik configuration
- **File extension requirement**: Use `.yaml` not `.yml` (Coolify requirement)
- **Domain configuration**: Set `COGNEE_DOMAIN` in .env for HTTPS/TLS
- **Health checks**: Configured for all services

Deploy via Coolify:
1. Add as "Docker Compose Empty" or Git Repository
2. Copy docker-compose.yaml content
3. Add all environment variables from env.example
4. Deploy

## Code Style & Conventions

### Python (FastAPI)
- Use **async/await** for all endpoints and database operations
- **Type hints** required for all function parameters and returns
- **Pydantic models** for request/response validation
- **Logging**: Use structured logging with `logger.info()`, `logger.error()`
- **Error handling**: Wrap operations in try/except, raise HTTPException with status codes

### Docker
- Use **official images** (postgres:15-alpine, neo4j:5-community, qdrant/qdrant:latest)
- Include **health checks** for all services
- Use **named volumes** for data persistence
- Define **explicit networks** for service communication
- Set **resource limits** via environment variables (e.g., NEO4J_HEAP_SIZE)

### Commit Messages
Use conventional commits:
- `Add:` for new features
- `Fix:` for bug fixes  
- `Update:` for updates to existing features
- `Docs:` for documentation changes

### Security
- **Never commit** `.env` file or API keys
- Use `.gitignore` to exclude sensitive files
- Change **default passwords** in production
- Configure **CORS** appropriately (currently allows all origins - tighten for production)
- Use **HTTPS** with reverse proxy for production deployments

## Testing & Verification

Before submitting changes:

1. **Full deployment test:**
   ```powershell
   docker-compose down -v
   docker-compose up -d
   bash healthcheck.sh  # or manually test endpoints
   ```

2. **API endpoint validation:**
   Test all CRUD operations (add → cognify → search → reset)

3. **Configuration validation:**
   ```powershell
   docker-compose config
   docker-compose up --no-start
   ```

4. **Test with different LLM providers** (if provider-related changes)

## Important Notes

- **Windows compatibility**: This project runs on Windows with PowerShell. Shell scripts (`.sh`) require WSL, Git Bash, or similar Unix shell
- **Startup time**: First run takes 1-2 minutes for Neo4j initialization
- **Memory requirements**: At least 4GB RAM (Neo4j uses 2GB heap by default)
- **Disk space**: Minimum 10GB for data volumes
- **Port conflicts**: Ensure ports 5432, 6333, 7474, 7687, 8000 are available
- **API Documentation**: Available at http://localhost:8000/docs (Swagger UI)

## Goose Integration

This deployment is designed for Goose AI agent integration via Cognee MCP (Model Context Protocol). See:
- `GOOSE_INTEGRATION.md` for detailed setup
- Cognee MCP repository: https://github.com/topoteretes/cognee

## Service URLs

- **Cognee API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Neo4j Browser**: http://localhost:7474
- **Qdrant Dashboard**: http://localhost:6333/dashboard

## Related Documentation

- `README.md` - User-facing quick start and features
- `DEPLOYMENT.md` - Detailed deployment instructions
- `COOLIFY_DEPLOYMENT.md` - Coolify-specific deployment guide
- `CONTRIBUTING.md` - Contribution guidelines and testing procedures
- `GOOSE_INTEGRATION.md` - Goose AI agent integration setup
