# Cognee Documentation Reference

This document serves as an index and quick reference to the [Cognee Documentation](https://docs.cognee.ai/).

## 📚 Official Documentation

**Main Documentation Site:** [https://docs.cognee.ai/](https://docs.cognee.ai/)

**Introduction:** [https://docs.cognee.ai/getting-started/introduction](https://docs.cognee.ai/getting-started/introduction)

**GitHub Repository:** [https://github.com/topoteretes/cognee](https://github.com/topoteretes/cognee)

**Discord Community:** [https://discord.gg/cognee](https://discord.gg/cognee)

## 🎯 What is Cognee?

Cognee organizes your data into AI memory. It creates a graph of raw information, extracted concepts, and meaningful relationships you can query. Cognee solves the problem of stateless LLM calls by providing a memory layer that links documents together and creates the right context for every LLM call.

## 🧠 How Cognee Works

Cognee has three key operations:

1. **`.add`** — Prepare for cognification
   - Send in your data asynchronously
   - Cognee cleans and prepares your data so that the memory layer can be created

2. **`.cognify`** — Build a knowledge graph with embeddings
   - Splits documents into chunks
   - Extracts entities and relations
   - Links everything into a queryable graph
   - Serves as the basis for the memory layer

3. **`.search`** — Query with context
   - Combines vector similarity with graph traversal
   - Can fetch raw nodes, explore relationships, or generate natural-language answers through RAG
   - Always creates the right context for the LLM

4. **`.memify`** — Semantic enrichment of the graph _(coming soon)_
   - Enhances the knowledge graph with semantic understanding
   - Adds deeper contextual relationships

## 📖 Key Documentation Sections

### Getting Started
- **Introduction**: [Overview of Cognee](https://docs.cognee.ai/getting-started/introduction)
- **Installation**: Set up your environment and install Cognee
- **Quickstart**: Run your first knowledge graph example

### Core Concepts
- **Overview**: High-level architecture and concepts
- **Architecture**: System design and components
- **Building Blocks**: Core components and their roles
- **Main Operations**: `.add`, `.cognify`, `.search`, `.memify`
- **Further Concepts**: Advanced topics and patterns
- **Cognee Permissions System**: Access control and security

### Setup Configuration
- **Setup Configuration**: Initial configuration guide
- **LLM Providers**: OpenAI, Anthropic, Azure, Ollama, etc.
- **Structured Output Backends**: Output formatting options
- **Embedding Providers**: Vector embedding configuration
- **Relational Databases**: PostgreSQL and other SQL databases
- **Vector Stores**: Qdrant, Pinecone, Weaviate, etc.
- **Graph Stores**: Neo4j, NetworkX, etc.
- **Permissions Setup**: Security and access control
- **Cognee Community Adapters**: Community-contributed adapters

### Guides
- **Essentials**: Essential features and workflows
- **Customizing Cognee**: Customization and extension guides

### Examples
- **Use Cases**: Real-world application examples
- **Tutorials**: Step-by-step tutorials

### CLI
- **Cognee CLI Overview**: Command-line interface documentation

## 🔗 Quick Links

### Essential Pages
- **Introduction**: [Why AI memory matters](https://docs.cognee.ai/getting-started/introduction)
- **Installation**: [Set up your environment](https://docs.cognee.ai/getting-started/installation)
- **Quickstart**: [Run your first example](https://docs.cognee.ai/getting-started/quickstart)
- **Architecture**: [How Cognee is structured](https://docs.cognee.ai/core-concepts/architecture)
- **Main Operations**: [`.add`, `.cognify`, `.search`](https://docs.cognee.ai/core-concepts/main-operations)

### Configuration
- **LLM Providers**: [Configure AI models](https://docs.cognee.ai/setup-configuration/llm-providers)
- **Vector Stores**: [Set up Qdrant, Pinecone, etc.](https://docs.cognee.ai/setup-configuration/vector-stores)
- **Graph Stores**: [Configure Neo4j, NetworkX](https://docs.cognee.ai/setup-configuration/graph-stores)
- **Relational Databases**: [PostgreSQL setup](https://docs.cognee.ai/setup-configuration/relational-databases)

### Integration
- **MCP Server**: Model Context Protocol integration
- **HTTP API**: RESTful API endpoints
- **Python API**: Python SDK usage

## 🏗️ Architecture Overview

Cognee uses a multi-database architecture:

- **PostgreSQL**: Relational database for structured data
- **Neo4j**: Graph database for relationships and entities
- **Qdrant**: Vector database for embeddings and similarity search

## 🔧 Key Features

### Multi-Database Architecture
- PostgreSQL for relational data
- Neo4j for knowledge graphs
- Qdrant for vector search

### Multiple LLM Provider Support
- OpenAI (default)
- Anthropic Claude
- Azure OpenAI
- Ollama (local)

### Multiple Interfaces
- **RESTful API**: HTTP endpoints for all operations
- **Python API**: Python SDK for programmatic access
- **MCP Server**: Model Context Protocol integration for Goose and other agents
- **CLI**: Command-line interface

### Search Modes
- **Vector Similarity**: Semantic search using embeddings
- **Graph Traversal**: Explore relationships and connections
- **Hybrid**: Combines both approaches for best results
- **RAG**: Generate natural-language answers with context

## 📝 Common Operations

### Adding Data
```python
# Add documents asynchronously
cognee.add(data=["document1.txt", "document2.txt"], dataset_id="my_dataset")
```

### Building Knowledge Graph
```python
# Cognify to build relationships
cognee.cognify(dataset_id="my_dataset")
```

### Searching
```python
# Search with context
results = cognee.search("query text", dataset_id="my_dataset")
```

## 🎓 Learning Path

1. **Start Here**: Read the [Introduction](https://docs.cognee.ai/getting-started/introduction)
2. **Install**: Follow the [Installation Guide](https://docs.cognee.ai/getting-started/installation)
3. **Quickstart**: Run your [first example](https://docs.cognee.ai/getting-started/quickstart)
4. **Core Concepts**: Understand [Architecture](https://docs.cognee.ai/core-concepts/architecture) and [Main Operations](https://docs.cognee.ai/core-concepts/main-operations)
5. **Configure**: Set up [LLM Providers](https://docs.cognee.ai/setup-configuration/llm-providers) and [Databases](https://docs.cognee.ai/setup-configuration/relational-databases)
6. **Integrate**: Connect with [Goose](GOOSE_INTEGRATION.md) or use the [HTTP API](https://docs.cognee.ai/integrations/http-api)

## 📚 Related Documentation

### In This Repository
- [README.md](README.md) - Self-hosted deployment guide
- [GOOSE_INTEGRATION.md](GOOSE_INTEGRATION.md) - Goose + Cognee integration
- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment instructions
- [COOLIFY_DEPLOYMENT.md](COOLIFY_DEPLOYMENT.md) - Coolify-specific guide
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Command cheat sheet

### External Resources
- [Cognee GitHub](https://github.com/topoteretes/cognee)
- [Cognee Discord](https://discord.gg/cognee)
- [MCP Protocol Spec](https://modelcontextprotocol.io/)
- [Goose Documentation](https://block.github.io/goose/docs/)

## 🔍 Key Concepts

### AI Memory
- **Problem**: LLMs are stateless - each request is independent
- **Solution**: Cognee creates a persistent memory layer
- **Benefit**: Context carries forward across sessions

### Knowledge Graph
- **Nodes**: Entities and concepts from your documents
- **Edges**: Relationships between entities
- **Embeddings**: Vector representations for semantic search
- **Metadata**: Additional context and properties

### Data Flow
1. **Add**: Documents are ingested and prepared
2. **Cognify**: Entities and relationships are extracted
3. **Search**: Queries combine vector and graph search
4. **Memify**: _(Coming soon)_ Semantic enrichment

## 💡 Tips

- **Start Small**: Begin with a few documents to understand the flow
- **Use Datasets**: Organize data by project or domain
- **Cognify Regularly**: Re-run cognify after adding new data
- **Experiment with Search Modes**: Try different search approaches
- **Monitor Resources**: Large datasets need adequate resources

## 🔄 Keeping Up to Date

- **Documentation**: Check [https://docs.cognee.ai/](https://docs.cognee.ai/) regularly
- **GitHub**: Watch [releases](https://github.com/topoteretes/cognee/releases)
- **Discord**: Join the [community](https://discord.gg/cognee) for updates
- **Changelog**: Review changelog for breaking changes

## 🆘 Getting Help

- **Documentation**: [https://docs.cognee.ai/](https://docs.cognee.ai/)
- **GitHub Issues**: [Report bugs and request features](https://github.com/topoteretes/cognee/issues)
- **Discord Community**: [Get help from the community](https://discord.gg/cognee)
- **Examples**: Check the [Examples section](https://docs.cognee.ai/examples) for use cases

---

**Last Updated**: This reference is maintained alongside the Cognee self-hosted deployment project. For the most current information, always refer to the [official Cognee documentation](https://docs.cognee.ai/).

