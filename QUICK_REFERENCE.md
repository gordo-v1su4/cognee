# Cognee Self-Hosted - Quick Reference

Quick commands and tips for managing your Cognee deployment.

## 🚀 Quick Start

```bash
# First time setup
cp env.example .env
# Edit .env with your API keys and passwords
./quickstart.sh

# Or manual start
docker-compose up -d
```

## 📊 Service URLs

| Service | URL | Description |
|---------|-----|-------------|
| Cognee API | http://localhost:8000 | Main API endpoint |
| API Docs | http://localhost:8000/docs | Interactive Swagger UI |
| Neo4j Browser | http://localhost:7474 | Graph database UI |
| Qdrant | http://localhost:6333/dashboard | Vector database |

## 🔧 Common Commands

### Docker Management

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Restart a service
docker-compose restart cognee

# View logs (all services)
docker-compose logs -f

# View logs (specific service)
docker-compose logs -f cognee
docker-compose logs -f neo4j
docker-compose logs -f postgres
docker-compose logs -f qdrant

# Check service status
docker-compose ps

# Check resource usage
docker stats

# Remove everything (including data)
docker-compose down -v
```

### Health Checks

```bash
# Run health check script
./healthcheck.sh

# Manual health checks
curl http://localhost:8000/health
curl http://localhost:8000/status
curl http://localhost:6333/health
curl http://localhost:7474
```

### API Operations

```bash
# Add data
curl -X POST http://localhost:8000/add \
  -H "Content-Type: application/json" \
  -d '{"data": "Your text here", "dataset_name": "my-project"}'

# Cognify (build knowledge graph)
curl -X POST http://localhost:8000/cognify \
  -H "Content-Type: application/json" \
  -d '{"dataset_name": "my-project"}'

# Search
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "What is this about?", "mode": "default"}'

# Get status
curl http://localhost:8000/status

# Reset (clears all data!)
curl -X DELETE http://localhost:8000/reset
```

### Backup & Restore

```bash
# Backup PostgreSQL
docker-compose exec postgres pg_dump -U cognee cognee > backup-$(date +%Y%m%d).sql

# Restore PostgreSQL
cat backup-20240101.sql | docker-compose exec -T postgres psql -U cognee cognee

# Backup Neo4j
docker-compose exec neo4j neo4j-admin dump --database=neo4j --to=/tmp/backup.dump
docker cp cognee-neo4j:/tmp/backup.dump ./neo4j-backup-$(date +%Y%m%d).dump

# Backup all volumes
docker-compose down
tar -czf cognee-backup-$(date +%Y%m%d).tar.gz *_data/
docker-compose up -d
```

## 🐛 Troubleshooting

### Services Won't Start

```bash
# Check logs
docker-compose logs cognee

# Verify configuration
docker-compose config

# Check port conflicts
netstat -tuln | grep -E '8000|7474|7687|6333|5432'

# Restart everything
docker-compose down
docker-compose up -d
```

### Connection Issues

```bash
# Test Cognee API
curl -v http://localhost:8000/health

# Check if services are running
docker-compose ps

# Verify environment variables
docker-compose exec cognee env | grep -E 'LLM|NEO4J|POSTGRES'
```

### Performance Issues

```bash
# Check resource usage
docker stats

# Reduce Neo4j memory (edit .env)
NEO4J_HEAP_SIZE=1G

# View slow queries in Neo4j
# Visit http://localhost:7474 and run:
# :queries
```

### Reset Everything

```bash
# Stop and remove everything
docker-compose down -v

# Clean up Docker system
docker system prune -a

# Start fresh
./quickstart.sh
```

## 🤖 Goose Integration

### Quick Setup

```bash
# Install UV
curl -LsSf https://astral.sh/uv/install.sh | sh

# Clone Cognee MCP
git clone https://github.com/topoteretes/cognee.git
cd cognee/cognee-mcp
uv sync --dev --all-extras --reinstall
```

### Configure Goose

Edit `~/.config/goose/profiles.yaml`:

```yaml
mcp_servers:
  cognee:
    command: uv
    args:
      - --directory
      - /ABSOLUTE/PATH/TO/cognee-mcp
      - run
      - python
      - src/server.py
    env:
      COGNEE_API_URL: http://localhost:8000
      LLM_API_KEY: ${LLM_API_KEY}
      EMBEDDING_API_KEY: ${EMBEDDING_API_KEY}
```

### Start Goose

```bash
export LLM_API_KEY="your_key"
export EMBEDDING_API_KEY="your_key"
goose session start
```

## 📝 Environment Variables

### Required

```bash
LLM_API_KEY=your_openai_key
EMBEDDING_API_KEY=your_openai_key
POSTGRES_PASSWORD=secure_password
NEO4J_PASSWORD=secure_password
```

### Optional

```bash
LLM_PROVIDER=openai          # openai, anthropic, azure, ollama
LLM_MODEL=gpt-4
EMBEDDING_PROVIDER=openai
EMBEDDING_MODEL=text-embedding-3-small
LOG_LEVEL=INFO
NEO4J_HEAP_SIZE=2G
```

## 🔐 Security Checklist

- [ ] Changed default passwords in `.env`
- [ ] Using strong passwords (16+ characters)
- [ ] Not exposing database ports publicly
- [ ] Using HTTPS in production
- [ ] Regular backups configured
- [ ] Monitoring logs for errors
- [ ] Updated to latest versions

## 📊 Monitoring

### Check Logs

```bash
# Follow all logs
docker-compose logs -f

# Last 100 lines
docker-compose logs --tail=100

# Since last hour
docker-compose logs --since=1h

# Errors only
docker-compose logs | grep -i error
```

### System Resources

```bash
# Docker stats
docker stats --no-stream

# Disk usage
docker system df

# Volume sizes
docker volume ls -q | xargs docker volume inspect | grep -A 5 Mountpoint
```

## 🔄 Update Procedure

```bash
# Pull latest images
docker-compose pull

# Backup data first!
./backup.sh  # (create this script using backup commands above)

# Restart with new images
docker-compose up -d

# Check health
./healthcheck.sh
```

## 💡 Tips & Tricks

### Speed Up Startup

```bash
# Pre-pull images
docker-compose pull
```

### Reduce Memory Usage

Edit `.env`:
```bash
NEO4J_HEAP_SIZE=1G  # Default is 2G
```

### Access Database Directly

```bash
# PostgreSQL
docker-compose exec postgres psql -U cognee cognee

# Neo4j Cypher Shell
docker-compose exec neo4j cypher-shell -u neo4j -p your_password
```

### View Knowledge Graph

1. Open http://localhost:7474
2. Login with credentials from `.env`
3. Run Cypher query:
   ```cypher
   MATCH (n) RETURN n LIMIT 100
   ```

### Export Data

```bash
# Export from Neo4j
docker-compose exec neo4j cypher-shell -u neo4j -p password \
  "MATCH (n) RETURN n" > graph-export.txt

# Export from PostgreSQL
docker-compose exec postgres pg_dump -U cognee cognee > postgres-export.sql
```

## 📖 Documentation Links

- [Full README](README.md) - Complete setup guide
- [Deployment Guide](DEPLOYMENT.md) - Coolify deployment
- [Goose Integration](GOOSE_INTEGRATION.md) - Detailed Goose setup
- [Contributing](CONTRIBUTING.md) - How to contribute

## 🆘 Getting Help

1. Check logs: `docker-compose logs -f`
2. Run health check: `./healthcheck.sh`
3. Review documentation
4. Check GitHub issues
5. Join Discord community

## 📞 Support Resources

- [Cognee Docs](https://docs.cognee.ai/)
- [Cognee GitHub](https://github.com/topoteretes/cognee)
- [Goose Docs](https://block.github.io/goose/)
- [Docker Docs](https://docs.docker.com/)
- [Coolify Docs](https://coolify.io/docs)

---

**Last Updated:** 2025-01-10  
**Version:** 1.0.0

