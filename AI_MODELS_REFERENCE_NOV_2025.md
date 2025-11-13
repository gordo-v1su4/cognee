# AI Models Reference - November 2025
**Last Updated: November 13, 2025**

## 🚀 Latest Model Releases

### OpenAI GPT-5.1 (Released November 12-13, 2025)

**Status:** ✅ Available via ChatGPT Web Interface | ⚠️ API Coming Soon

#### Model Variants
- **GPT-5.1 Instant** - Faster responses, optimized for speed
- **GPT-5.1 Thinking** - Enhanced reasoning, deeper analysis

#### Key Features
- **2-3x faster** than GPT-5
- **50% fewer tokens** used compared to competitors on reasoning tasks
- Improved instruction-following
- Better parallel tool calling
- Enhanced coding capabilities
- Warmer, more conversational tone
- 8 new personality types available

#### API Status
- **Current:** Available in ChatGPT web interface only
- **Coming Soon:** API access for developers
- When available, use model ID: `gpt-5.1`

---

## 📊 Available OpenAI Models (November 2025)

### Production Models (API Available)

| Model | Status | Best For | Context Window | Notes |
|-------|--------|----------|----------------|-------|
| **gpt-4o** | ✅ Available | General purpose, multimodal | ~128K tokens | Fastest GPT-4 class model |
| **gpt-4o-mini** | ✅ Available | Cost-effective tasks | ~128K tokens | Budget-friendly option |
| **gpt-4-turbo** | ✅ Available | Complex tasks | ~128K tokens | Previous generation |
| **gpt-3.5-turbo** | ✅ Available | Simple tasks, high volume | ~16K tokens | Legacy model |
| **text-embedding-3-small** | ✅ Available | Embeddings | N/A | Latest embedding model |
| **text-embedding-3-large** | ✅ Available | High-quality embeddings | N/A | More dimensions |

### Reasoning Models

| Model | Status | Best For | Notes |
|-------|--------|----------|-------|
| **o1** | ✅ Available | Deep reasoning | ChatGPT Pro exclusive |
| **o1-mini** | ✅ Available | Faster reasoning | More accessible |
| **o1-pro** | ✅ Available | Advanced reasoning | ChatGPT Pro exclusive |

### Latest Models (ChatGPT Only)

| Model | API Status | Web Status | Notes |
|-------|------------|------------|-------|
| **GPT-5** | ❌ Not Available | ✅ Legacy (3 months) | Being phased out |
| **GPT-5.1** | ⏳ Coming Soon | ✅ Available Now | New default |
| **GPT-5 Pro** | ❌ Not Available | ✅ Pro Only | Advanced capabilities |

---

## 🤖 Competitor Models (November 2025)

### Anthropic Claude

| Model | Version | Best For | Context Window | API Access |
|-------|---------|----------|----------------|------------|
| **Claude Opus** | 4.1 | Frontier tasks, complex reasoning | ~200K tokens | ✅ Claude API, AWS Bedrock, Vertex AI |
| **Claude Sonnet** | 4.5 | Coding, AI agents | ~200K tokens | ✅ Claude API, AWS Bedrock, Vertex AI |
| **Claude Haiku** | 4.5 | Fast, cost-effective | ~200K tokens | ✅ Claude API, AWS Bedrock, Vertex AI |

### Google Gemini

| Model | Version | Best For | Context Window | API Access |
|-------|---------|----------|----------------|------------|
| **Gemini Pro** | 2.5 | Long-context tasks | ~1M tokens | ✅ Google AI Studio, Vertex AI |
| **Gemini Flash** | 2.5 | Fast responses | ~1M tokens | ✅ Google AI Studio, Vertex AI |

---

## 💡 Recommended Models for Cognee (November 2025)

### Primary Recommendation
```yaml
LLM_PROVIDER: openai
LLM_MODEL: gpt-4o
EMBEDDING_PROVIDER: openai
EMBEDDING_MODEL: text-embedding-3-small
```

**Why:**
- ✅ **Available via API** (GPT-5.1 not yet available)
- ✅ Proven stability in production
- ✅ Fast and cost-effective
- ✅ Excellent for reasoning and embeddings

### When GPT-5.1 API Becomes Available
```yaml
LLM_PROVIDER: openai
LLM_MODEL: gpt-5.1
EMBEDDING_PROVIDER: openai
EMBEDDING_MODEL: text-embedding-3-small
```

**Benefits:**
- 🚀 2-3x faster than GPT-5
- 💰 50% fewer tokens on reasoning tasks
- 🎯 Better instruction-following
- 🔧 Improved tool calling

### Alternative: Claude Sonnet (for coding/agents)
```yaml
LLM_PROVIDER: anthropic
LLM_MODEL: claude-sonnet-4.5
EMBEDDING_PROVIDER: openai
EMBEDDING_MODEL: text-embedding-3-small
```

**Why:**
- 🔧 Excellent for AI agents
- 💻 Superior coding capabilities
- 📝 Strong JSON/structured outputs
- 🔗 Tool use optimization

---

## 🔄 Model Migration Timeline

### Current (November 13, 2025)
- **Recommended:** `gpt-4o` (stable, API-ready)
- **Alternative:** `claude-sonnet-4.5` (agents/coding)

### Near Future (Expected: December 2025)
- **Switch to:** `gpt-5.1` when API available
- **Monitor:** OpenAI API announcements

### Legacy Models (Being Phased Out)
- ❌ `gpt-5` - Available for 3 months, then deprecated
- ⚠️ `gpt-4` - Consider upgrading to `gpt-4o`
- ⚠️ `gpt-3.5-turbo` - Use only for simple tasks

---

## 📚 Sources & References

1. **OpenAI GPT-5.1 Announcement**
   - Released: November 12-13, 2025
   - [OpenAI Blog](https://openai.com/index/gpt-5-1/)
   - [Developer Docs](https://openai.com/index/gpt-5-1-for-developers/)

2. **GitHub Copilot Integration**
   - GPT-5.1, GPT-5.1-Codex, GPT-5.1-Codex-Mini
   - Public preview announced November 13, 2025

3. **Model Comparison**
   - [ChatGPT 5.1 vs Claude vs Gemini](https://skywork.ai/blog/ai-agent/chatgpt-5-1-vs-claude-vs-gemini-2025-comparison/)

4. **API Documentation**
   - [OpenAI Platform Docs](https://platform.openai.com/docs/)
   - [Anthropic Claude Docs](https://docs.anthropic.com/)
   - [Google AI Studio](https://ai.google.dev/)

---

## ⚡ Quick Reference

### For API Integration (Today)
```bash
# Best available option
LLM_MODEL=gpt-4o

# Budget option
LLM_MODEL=gpt-4o-mini

# Embeddings (unchanged)
EMBEDDING_MODEL=text-embedding-3-small
```

### For ChatGPT Web (Today)
- Default: GPT-5.1 (Instant & Thinking)
- Legacy: GPT-5 (available for 3 months)
- Pro: o1, o1-pro, GPT-5 Pro

---

**Note:** This document should be updated when:
1. GPT-5.1 API becomes available
2. New major model releases occur
3. Pricing or availability changes significantly

**Check for updates:** Monthly or when starting new projects
