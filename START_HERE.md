# 🚀 START HERE - Cognee Self-Hosted Quick Start

**Welcome!** This guide will get you up and running in **3 simple steps**.

## 📋 What You Need

- [ ] Docker Desktop installed ([Get Docker](https://www.docker.com/products/docker-desktop/))
- [ ] OpenAI API key ([Get API Key](https://platform.openai.com/api-keys))
- [ ] 10 minutes of your time ⏱️

## 🎯 3-Step Quick Start

### Step 1️⃣: Configure Environment (2 minutes)

```bash
# Copy the template
cp env.example .env

# Edit the file (use notepad, nano, or any editor)
nano .env
```

**Update these 4 values:**
```env
LLM_API_KEY=sk-your-openai-key-here          # ← Your OpenAI API key
EMBEDDING_API_KEY=sk-your-openai-key-here    # ← Same key is fine
POSTGRES_PASSWORD=your-secure-password-123   # ← Make it strong!
NEO4J_PASSWORD=another-secure-password-456   # ← Different password
```

💡 **Tip:** On Windows? See [WINDOWS_SETUP.md](WINDOWS_SETUP.md) for Windows-specific instructions.

### Step 2️⃣: Start Services (3 minutes)

**Option A: Automated (Recommended)**
```bash
./quickstart.sh
```

**Option B: Manual**
```bash
docker-compose up -d
```

**On Windows PowerShell:**
```powershell
docker-compose up -d
```

⏳ **Wait 1-2 minutes** for services to initialize...

### Step 3️⃣: Verify It Works (1 minute)

```bash
# Check health
curl http://localhost:8000/health

# Or visit in browser:
# http://localhost:8000/docs
```

**Expected response:**
```json
{"status": "healthy", "service": "cognee-api"}
```

🎉 **Success!** You now have:
- ✅ Cognee API running at http://localhost:8000
- ✅ Neo4j graph database at http://localhost:7474
- ✅ Qdrant vector store at http://localhost:6333
- ✅ PostgreSQL database (internal)

## 🧪 Try It Out (2 minutes)

### Add Some Data

```bash
curl -X POST http://localhost:8000/add \
  -H "Content-Type: application/json" \
  -d '{
    "data": "Cognee is an AI memory system that builds knowledge graphs",
    "dataset_name": "intro"
  }'
```

### Build Knowledge Graph

```bash
curl -X POST http://localhost:8000/cognify \
  -H "Content-Type: application/json" \
  -d '{"dataset_name": "intro"}'
```

### Search Your Data

```bash
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What is Cognee?",
    "mode": "default"
  }'
```

🎊 **It works!** You've just:
1. ✅ Added data to AI memory
2. ✅ Built a knowledge graph
3. ✅ Searched with context

## 🤖 Bonus: Add Goose Integration (Optional, 15 minutes)

Want to use Cognee with [Goose AI agent](https://block.github.io/goose/)? 

👉 Follow: [GOOSE_INTEGRATION.md](GOOSE_INTEGRATION.md)

**Why use Goose + Cognee?**
- 🧠 Give Goose persistent memory
- 📚 Build knowledge graphs from your codebase
- 🔍 Search across all your documents with context
- 🤝 Maintain memory across sessions

## 📚 What's Next?

### For Local Development

✅ **You're ready!** Start using the API:
- 📖 Read [README.md](README.md) for full API documentation
- 🎯 Check [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for common commands
- 💡 Browse http://localhost:8000/docs for interactive API docs

### For Production Deployment

Want to deploy to Coolify? **Easy!**

👉 Follow: [DEPLOYMENT.md](DEPLOYMENT.md)

**Coolify Benefits:**
- ✅ One-click deployment
- ✅ Automatic SSL/HTTPS
- ✅ Easy updates and rollbacks
- ✅ Built-in monitoring
- ✅ No DevOps headaches

## 🆘 Something Not Working?

### Services won't start?

```bash
# Check what's wrong
docker-compose logs -f

# Try restarting
docker-compose down
docker-compose up -d
```

### Can't access the API?

```bash
# Check if containers are running
docker-compose ps

# All should show "Up" status
```

### Still stuck?

1. 📖 Check [TROUBLESHOOTING section in README.md](README.md#troubleshooting)
2. 🪟 On Windows? See [WINDOWS_SETUP.md](WINDOWS_SETUP.md)
3. 💬 Ask in [Cognee Discord](https://discord.gg/cognee)

## 📖 Documentation Overview

| Document | Use When... |
|----------|------------|
| **START_HERE.md** (this file) | First time setup |
| [README.md](README.md) | Full documentation & features |
| [QUICK_REFERENCE.md](QUICK_REFERENCE.md) | Need quick commands |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Deploy to Coolify |
| [GOOSE_INTEGRATION.md](GOOSE_INTEGRATION.md) | Integrate with Goose |
| [WINDOWS_SETUP.md](WINDOWS_SETUP.md) | Using Windows |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Want to contribute |

## 🎓 Learning Path

**Beginner:**
1. ✅ Complete this quick start
2. 📖 Read [README.md](README.md)
3. 🧪 Try API examples at http://localhost:8000/docs

**Intermediate:**
4. 🤖 Setup [Goose integration](GOOSE_INTEGRATION.md)
5. 🔍 Explore Neo4j graph at http://localhost:7474
6. 📊 Check Qdrant dashboard at http://localhost:6333/dashboard

**Advanced:**
7. 🚀 Deploy to production with [Coolify](DEPLOYMENT.md)
8. 🔧 Customize LLM providers (OpenAI, Claude, Ollama)
9. 🏗️ Build your own applications on top

## 💡 Use Cases

**What can you build?**

🤖 **Development Assistant**
- Document your codebase automatically
- Search code patterns with context
- Build knowledge from technical docs

📚 **Knowledge Management**
- Create interconnected knowledge bases
- Semantic search across documents
- Extract entities and relationships

🎯 **RAG Applications**
- Context-aware chatbots
- Intelligent documentation systems
- Domain-specific AI assistants

## ⚡ Quick Commands Cheat Sheet

```bash
# Start everything
docker-compose up -d

# Stop everything
docker-compose down

# View logs
docker-compose logs -f

# Check health
curl http://localhost:8000/health

# Open API docs
open http://localhost:8000/docs  # macOS
start http://localhost:8000/docs  # Windows

# Restart service
docker-compose restart cognee

# Remove all data (careful!)
docker-compose down -v
```

## 🎯 Your Checklist

Track your progress:

- [ ] Installed Docker Desktop
- [ ] Created and configured `.env` file
- [ ] Started services with `docker-compose up -d`
- [ ] Verified health at http://localhost:8000/health
- [ ] Tested add/cognify/search APIs
- [ ] Explored API docs at http://localhost:8000/docs
- [ ] (Optional) Installed and configured Goose
- [ ] (Optional) Deployed to Coolify

## 🎉 You're All Set!

**Congratulations!** You now have a fully functional Cognee instance running.

**What to do next:**
1. Start adding your data
2. Build knowledge graphs
3. Integrate with your applications
4. Share with your team!

---

**Need Help?**
- 💬 [Cognee Discord](https://discord.gg/cognee)
- 📧 Check GitHub issues
- 📖 Read the docs

**Enjoying Cognee?**
- ⭐ Star the repo
- 🐦 Share on social media
- 🤝 Contribute improvements

**Happy building! 🚀**

---

*Created: 2025-11-10 | Version: 1.0.0*

