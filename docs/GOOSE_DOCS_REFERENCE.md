# Goose Documentation Reference

This document serves as an index and quick reference to the [Goose Documentation](https://block.github.io/goose/docs/).

## 📚 Official Documentation

**Main Documentation Site:** [https://block.github.io/goose/docs/](https://block.github.io/goose/docs/)

**GitHub Repository:** [https://github.com/block/goose](https://github.com/block/goose)

## 🎯 What is Goose?

Goose is a local AI agent that automates engineering tasks seamlessly. It connects to external services via Model Context Protocol (MCP) servers, enabling powerful integrations with tools like Cognee.

## 📖 Key Documentation Sections

### Getting Started
- Installation guides for macOS, Linux, and Windows
- Quick start tutorials
- Basic configuration

### Configuration
- **Profiles**: `~/.config/goose/profiles.yaml`
- Provider configuration (OpenAI, Anthropic, Azure, etc.)
- Processor and accelerator settings
- Moderator configuration

### MCP Servers
- Model Context Protocol (MCP) overview
- Adding MCP servers to Goose
- Cognee MCP integration
- Other MCP server examples

### Toolkits
- Developer toolkit
- GitHub toolkit
- Custom toolkit configuration

### Advanced Usage
- Session management
- Memory and context handling
- Advanced workflows
- Performance optimization

### Tutorials
- [Advanced Cognee Usage with Goose](https://block.github.io/goose/docs/tutorials/advanced-cognee-usage/)
- Integration patterns
- Best practices

## 🔗 Quick Links

### Essential Pages
- **Installation**: Installation scripts and platform-specific guides
- **Configuration**: Profile setup and environment variables
- **MCP Integration**: How to connect MCP servers like Cognee
- **API Reference**: Command-line interface and API documentation

### Cognee-Specific
- **Cognee MCP Setup**: Integration guide for Cognee
- **Advanced Cognee Usage**: Tutorial on using Cognee with Goose
- **Memory Management**: How Goose uses Cognee for persistent memory

## 🛠️ Common Commands

### Installation
```bash
# macOS/Linux
curl -fsSL https://raw.githubusercontent.com/block/goose/main/install.sh | bash

# Windows (PowerShell)
irm https://raw.githubusercontent.com/block/goose/main/install.ps1 | iex
```

### Basic Usage
```bash
# Start a Goose session
goose session start

# Configure Goose
goose configure

# Check version
goose --version
```

## 📝 Configuration Reference

### Basic Profile Structure
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
        - /path/to/cognee-mcp
        - run
        - python
        - src/server.py
      env:
        COGNEE_API_URL: http://localhost:8000
        LLM_API_KEY: ${LLM_API_KEY}
        EMBEDDING_API_KEY: ${EMBEDDING_API_KEY}
```

## 🔍 Key Concepts

### Providers
- **OpenAI**: Default provider, supports GPT-4, GPT-3.5
- **Anthropic**: Claude models
- **Azure OpenAI**: Enterprise OpenAI deployments
- **Ollama**: Local model hosting

### Processors
- Main AI model for processing tasks
- Examples: `gpt-4`, `gpt-3.5-turbo`, `claude-3-opus`

### Accelerators
- Secondary model for faster operations
- Can be different from processor

### Moderators
- Control how Goose handles requests
- Options: `passive`, `active`, `strict`

### MCP Servers
- Model Context Protocol servers extend Goose capabilities
- Cognee provides an MCP server for AI memory and knowledge graphs
- Other MCP servers available in the ecosystem

## 📚 Related Documentation

### In This Repository
- [GOOSE_INTEGRATION.md](GOOSE_INTEGRATION.md) - Complete Cognee + Goose integration guide
- [README.md](README.md) - Main Cognee deployment documentation
- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment instructions

### External Resources
- [MCP Protocol Specification](https://modelcontextprotocol.io/)
- [Cognee Documentation](https://docs.cognee.ai/)
- [Goose GitHub Issues](https://github.com/block/goose/issues)

## 🎓 Learning Path

1. **Start Here**: Read the [Goose Documentation](https://block.github.io/goose/docs/) getting started guide
2. **Install Goose**: Follow installation instructions for your platform
3. **Basic Configuration**: Set up your first profile
4. **Add Cognee**: Follow [GOOSE_INTEGRATION.md](GOOSE_INTEGRATION.md) to integrate Cognee
5. **Advanced Usage**: Explore tutorials and advanced features

## 💡 Tips

- **Keep Documentation Updated**: Goose documentation is actively maintained
- **Check GitHub**: Latest features and fixes are documented in GitHub releases
- **Community Support**: Join discussions on GitHub Issues for help
- **Experiment**: Try different providers and configurations to find what works best

## 🔄 Keeping Up to Date

- **Documentation**: Check [https://block.github.io/goose/docs/](https://block.github.io/goose/docs/) regularly
- **Releases**: Watch [GitHub Releases](https://github.com/block/goose/releases)
- **Changelog**: Review changelog for breaking changes

---

**Last Updated**: This reference is maintained alongside the Cognee project. For the most current information, always refer to the [official Goose documentation](https://block.github.io/goose/docs/).

