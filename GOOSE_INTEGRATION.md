# Integrating Cognee with Goose

This guide explains how to integrate your self-hosted Cognee instance with Goose AI agent.

## What is Goose?

[Goose](https://block.github.io/goose/) is your local AI agent that automates engineering tasks seamlessly. It can connect to external services via Model Context Protocol (MCP) servers.

## What is Cognee MCP?

Cognee provides an MCP server that allows Goose to:
- Add files and documents to AI memory
- Build knowledge graphs from your codebase
- Search across your documents with context
- Query relationships between concepts
- Maintain persistent memory across sessions

## Prerequisites

- Self-hosted Cognee instance running (see [DEPLOYMENT.md](DEPLOYMENT.md))
- Goose installed on your local machine
- Python 3.11+ and `uv` package manager

## Installation Steps

### Step 1: Install Goose

If you haven't installed Goose yet:

```bash
# On macOS/Linux
curl -fsSL https://raw.githubusercontent.com/block/goose/main/install.sh | bash

# On Windows (PowerShell)
irm https://raw.githubusercontent.com/block/goose/main/install.ps1 | iex

# Verify installation
goose --version
```

### Step 2: Install UV Package Manager

Cognee MCP requires `uv` for dependency management:

```bash
# On macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# On Windows (PowerShell)
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"

# Verify installation
uv --version
```

### Step 3: Clone and Setup Cognee MCP

```bash
# Clone the Cognee repository
git clone https://github.com/topoteretes/cognee.git
cd cognee/cognee-mcp

# Install dependencies
uv sync --dev --all-extras --reinstall

# On Linux, you may need additional system dependencies
sudo apt install -y libpq-dev python3-dev
```

### Step 4: Configure Goose

Create or edit your Goose configuration file at `~/.config/goose/profiles.yaml`:

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
        - /path/to/cognee/cognee-mcp  # CHANGE THIS to your actual path!
        - run
        - python
        - src/server.py
      env:
        # Your self-hosted Cognee URL
        COGNEE_API_URL: http://localhost:8000  # or your Coolify domain
        
        # API keys for LLM and embeddings
        LLM_API_KEY: ${LLM_API_KEY}
        EMBEDDING_API_KEY: ${EMBEDDING_API_KEY}
        
        # Optional: specify providers if different from OpenAI
        # LLM_PROVIDER: openai
        # EMBEDDING_PROVIDER: openai
```

**Important:** Update the following in the configuration:
- Replace `/path/to/cognee/cognee-mcp` with the **absolute path** to your cognee-mcp directory
- Replace `http://localhost:8000` with your Coolify deployment URL if not running locally
- Set `LLM_API_KEY` and `EMBEDDING_API_KEY` environment variables

### Step 5: Set Environment Variables

Add to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
export LLM_API_KEY="your_openai_api_key"
export EMBEDDING_API_KEY="your_openai_api_key"
```

Or for the current session:

```bash
export LLM_API_KEY="your_openai_api_key"
export EMBEDDING_API_KEY="your_openai_api_key"
```

### Step 6: Test the Integration

```bash
# Start Goose session
goose session start

# You should see Cognee MCP server listed in the startup
# Try some commands:
```

In the Goose prompt:

```
# Add current file to Cognee
"Add this file to memory"

# Add multiple files
"Add all Python files in src/ to Cognee memory"

# Search your knowledge base
"Search Cognee for authentication patterns in my project"

# Build knowledge graph
"Cognify my project files to build a knowledge graph"

# Query relationships
"What are the relationships between the User and Auth modules?"
```

## Usage Examples

### Example 1: Document Your Codebase

```bash
goose session start
```

Then in Goose:
```
"Add all files in my src/ directory to Cognee memory, 
then build a knowledge graph and give me a summary 
of the architecture"
```

### Example 2: Search Across Documentation

```bash
goose session start
```

Then:
```
"Search Cognee for all mentions of database migrations 
and show me the related files"
```

### Example 3: Build Project Memory

```bash
goose session start
```

Then:
```
"Add README.md, all Python files, and requirements.txt to Cognee.
Then cognify to build relationships and tell me what 
dependencies are used for database operations."
```

### Example 4: Contextual Code Search

```bash
goose session start
```

Then:
```
"Search Cognee for error handling patterns in my API routes
and suggest improvements based on what you find"
```

## Advanced Configuration

### Using Different LLM Providers

#### Anthropic Claude

```yaml
mcp_servers:
  cognee:
    command: uv
    args: [...]
    env:
      COGNEE_API_URL: http://localhost:8000
      LLM_PROVIDER: anthropic
      ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY}
      EMBEDDING_API_KEY: ${OPENAI_API_KEY}
```

#### Azure OpenAI

```yaml
mcp_servers:
  cognee:
    command: uv
    args: [...]
    env:
      COGNEE_API_URL: http://localhost:8000
      LLM_PROVIDER: azure
      AZURE_OPENAI_ENDPOINT: https://your-endpoint.openai.azure.com/
      AZURE_OPENAI_API_KEY: ${AZURE_OPENAI_API_KEY}
      EMBEDDING_API_KEY: ${OPENAI_API_KEY}
```

#### Ollama (Local)

```yaml
mcp_servers:
  cognee:
    command: uv
    args: [...]
    env:
      COGNEE_API_URL: http://localhost:8000
      LLM_PROVIDER: ollama
      OLLAMA_BASE_URL: http://localhost:11434
      OLLAMA_MODEL: llama2
      EMBEDDING_API_KEY: ${OPENAI_API_KEY}
```

### Custom Search Modes

Cognee supports different search modes:

```
# Default mode (hybrid search)
"Search Cognee with default mode for authentication"

# Graph traversal mode
"Search Cognee using graph mode for related entities"

# Vector similarity mode
"Search Cognee using vector mode for similar concepts"
```

## Troubleshooting

### Issue: Goose Can't Connect to Cognee

**Check Cognee is Running:**
```bash
curl http://localhost:8000/health
```

**Verify Configuration:**
```bash
cat ~/.config/goose/profiles.yaml
```

**Check MCP Server Logs:**
```bash
# Logs are typically in Goose's log directory
tail -f ~/.goose/logs/mcp-cognee.log
```

### Issue: Authentication Errors

**Verify API Keys:**
```bash
echo $LLM_API_KEY
echo $EMBEDDING_API_KEY
```

**Test API Key:**
```bash
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $LLM_API_KEY"
```

### Issue: MCP Server Won't Start

**Check Python Installation:**
```bash
python3 --version
uv --version
```

**Verify Dependencies:**
```bash
cd /path/to/cognee-mcp
uv sync --dev --all-extras --reinstall
```

**Test MCP Server Manually:**
```bash
cd /path/to/cognee-mcp
export COGNEE_API_URL=http://localhost:8000
export LLM_API_KEY=your_key
export EMBEDDING_API_KEY=your_key
uv run python src/server.py
```

### Issue: Path Not Found

Make sure you use **absolute paths** in the configuration:

❌ Bad:
```yaml
- --directory
- ~/cognee/cognee-mcp  # Won't expand
```

✅ Good:
```yaml
- --directory
- /home/username/cognee/cognee-mcp  # Full path
```

## Tips for Best Results

1. **Start Small**: Add a few files first to test the integration
2. **Use Descriptive Queries**: More specific queries get better results
3. **Cognify Regularly**: After adding new files, run cognify to update the knowledge graph
4. **Monitor Memory**: Large codebases need more Cognee resources
5. **Organize by Datasets**: Use different dataset names for different projects

## Example Workflows

### Workflow 1: New Project Onboarding

```
1. "Add README.md to Cognee"
2. "Add all main source files to Cognee"
3. "Cognify to build knowledge graph"
4. "Summarize the project architecture from Cognee"
5. "What are the main entry points?"
```

### Workflow 2: Bug Investigation

```
1. "Search Cognee for error handling in API layer"
2. "Show relationships between Error classes"
3. "Find similar error patterns in other modules"
4. "Suggest improvements based on patterns"
```

### Workflow 3: Code Review Assistant

```
1. "Add the files in this PR to Cognee"
2. "Search Cognee for similar code patterns"
3. "Check if this follows our project conventions"
4. "Suggest tests based on similar components"
```

## Resources

- [Goose Documentation](https://block.github.io/goose/docs/) - Official documentation
- [Goose Documentation Reference](GOOSE_DOCS_REFERENCE.md) - Quick reference index
- [Cognee Documentation](https://docs.cognee.ai/)
- [Cognee Documentation Reference](COGNEE_DOCS_REFERENCE.md) - Quick reference index
- [MCP Protocol Spec](https://modelcontextprotocol.io/)
- [Advanced Cognee Usage with Goose](https://block.github.io/goose/docs/tutorials/advanced-cognee-usage/)

## Getting Help

- **Goose Issues**: [GitHub Issues](https://github.com/block/goose/issues)
- **Cognee Issues**: [GitHub Issues](https://github.com/topoteretes/cognee/issues)
- **Community Discord**: [Cognee Discord](https://discord.gg/cognee)

Happy coding with Goose and Cognee! 🚀

