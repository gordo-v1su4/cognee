# 🦢 Configuring Goose with Coolify-Hosted Cognee

**Your Cognee URL:** `https://cognee.v1su4.com`

This guide walks you through configuring Goose step-by-step, starting from Step 3.

---

## ✅ Prerequisites Check

Before starting, make sure you have:
- [ ] Goose installed (`goose --version` should work)
- [ ] UV package manager installed (`uv --version` should work)
- [ ] Your Cognee instance running at `https://cognee.v1su4.com`
- [ ] Your OpenAI API key ready

---

## Step 3: Clone and Setup Cognee MCP

### 3.1: Clone the Cognee Repository

Open your terminal/PowerShell and run:

```bash
# Clone the repository
git clone https://github.com/topoteretes/cognee.git
```

**Note:** If you already have the cognee repository cloned (maybe for deployment), you can use that same repository.

### 3.2: Navigate to the MCP Directory

```bash
cd cognee/cognee-mcp
```

### 3.3: Install Dependencies

```bash
# Install all dependencies
uv sync --dev --all-extras --reinstall
```

**On Windows:** This should work directly in PowerShell.

**On Linux:** You may need to install system dependencies first:
```bash
sudo apt install -y libpq-dev python3-dev
```

**Expected output:** You should see dependencies being installed. This may take a few minutes.

### 3.4: Verify Installation

```bash
# Check that the directory exists and has the right files
ls src/server.py
# Should show: src/server.py
```

**✅ Step 3 Complete!** You now have Cognee MCP installed locally.

---

## Step 4: Configure Goose

### 4.1: Find Your Cognee MCP Path

**Important:** You need the **absolute/full path** to the `cognee-mcp` directory.

**On Windows:**
```powershell
# In PowerShell, from the cognee-mcp directory:
pwd
# Copy the full path shown (e.g., C:\Users\Gordo\Documents\Github\cognee\cognee-mcp)
```

**On macOS/Linux:**
```bash
# From the cognee-mcp directory:
pwd
# Copy the full path shown (e.g., /home/username/cognee/cognee-mcp)
```

**📝 Write down this path** - you'll need it in the next step!

### 4.2: Create or Edit Goose Configuration

**On Windows:**
The config file is at: `C:\Users\<YourUsername>\.config\goose\profiles.yaml`

**On macOS/Linux:**
The config file is at: `~/.config/goose/profiles.yaml`

**Create the directory if it doesn't exist:**
```bash
# Windows PowerShell
mkdir -p $env:USERPROFILE\.config\goose

# macOS/Linux
mkdir -p ~/.config/goose
```

### 4.3: Open the Configuration File

**On Windows:**
```powershell
# Open in notepad
notepad $env:USERPROFILE\.config\goose\profiles.yaml

# Or use your preferred editor (VS Code, etc.)
code $env:USERPROFILE\.config\goose\profiles.yaml
```

**On macOS/Linux:**
```bash
# Open in nano (or your preferred editor)
nano ~/.config/goose/profiles.yaml

# Or with VS Code
code ~/.config/goose/profiles.yaml
```

### 4.4: Add or Update the Configuration

**If the file is empty or doesn't exist**, paste this entire configuration:

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
        - C:\Users\Gordo\Documents\Github\cognee\cognee-mcp  # ⚠️ CHANGE THIS to your actual path!
        - run
        - python
        - src/server.py
      env:
        # Your Coolify-hosted Cognee URL
        COGNEE_API_URL: https://cognee.v1su4.com
        
        # API keys (will use environment variables)
        LLM_API_KEY: ${LLM_API_KEY}
        EMBEDDING_API_KEY: ${EMBEDDING_API_KEY}
```

**If you already have a configuration file**, just add or update the `mcp_servers` section:

```yaml
mcp_servers:
  cognee:
    command: uv
    args:
      - --directory
      - C:\Users\Gordo\Documents\Github\cognee\cognee-mcp  # ⚠️ CHANGE THIS!
      - run
      - python
      - src/server.py
    env:
      COGNEE_API_URL: https://cognee.v1su4.com
      LLM_API_KEY: ${LLM_API_KEY}
      EMBEDDING_API_KEY: ${EMBEDDING_API_KEY}
```

### 4.5: Update the Path

**⚠️ CRITICAL:** Replace `C:\Users\Gordo\Documents\Github\cognee\cognee-mcp` with **your actual path** from Step 4.1.

**Windows example:**
```yaml
- C:\Users\YourName\Documents\cognee\cognee-mcp
```

**macOS/Linux example:**
```yaml
- /home/username/cognee/cognee-mcp
```

**Important:** Use forward slashes `/` even on Windows in YAML files, or use double backslashes `\\`.

### 4.6: Save the File

Save the configuration file and close your editor.

**✅ Step 4 Complete!** Goose is now configured to use your Coolify-hosted Cognee.

---

## Step 5: Set Environment Variables

### 5.1: Set Environment Variables for Current Session

**On Windows PowerShell:**
```powershell
$env:LLM_API_KEY = "sk-your-openai-api-key-here"
$env:EMBEDDING_API_KEY = "sk-your-openai-api-key-here"
```

**On macOS/Linux:**
```bash
export LLM_API_KEY="sk-your-openai-api-key-here"
export EMBEDDING_API_KEY="sk-your-openai-api-key-here"
```

**Replace** `sk-your-openai-api-key-here` with your actual OpenAI API key.

### 5.2: Verify Environment Variables Are Set

**On Windows PowerShell:**
```powershell
echo $env:LLM_API_KEY
echo $env:EMBEDDING_API_KEY
```

**On macOS/Linux:**
```bash
echo $LLM_API_KEY
echo $EMBEDDING_API_KEY
```

Both should show your API key (not empty).

### 5.3: (Optional) Make Environment Variables Permanent

**On Windows:**
- Open System Properties → Environment Variables
- Add `LLM_API_KEY` and `EMBEDDING_API_KEY` as User variables
- Or add to your PowerShell profile: `notepad $PROFILE`

**On macOS/Linux:**
Add to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):
```bash
export LLM_API_KEY="sk-your-openai-api-key-here"
export EMBEDDING_API_KEY="sk-your-openai-api-key-here"
```

Then reload:
```bash
source ~/.bashrc  # or ~/.zshrc
```

**✅ Step 5 Complete!** Environment variables are set.

---

## Step 6: Test the Integration

### 6.1: Verify Cognee is Accessible

First, make sure your Coolify-hosted Cognee is working:

```bash
# Test the health endpoint
curl https://cognee.v1su4.com/health
```

**Expected response:**
```json
{"status": "healthy", "service": "cognee-api"}
```

If this doesn't work, your Cognee instance might not be running. Check Coolify dashboard.

### 6.2: Start Goose Session

```bash
goose session start
```

**What to look for:**
- Goose should start successfully
- You should see Cognee MCP server listed in the startup messages
- No error messages about connection failures

### 6.3: Test Basic Commands

Once Goose is running, try these commands in the Goose prompt:

**Test 1: Check Cognee Connection**
```
"Can you check if Cognee is connected?"
```

**Test 2: Add Data to Cognee**
```
"Add this message to Cognee memory: 'I'm testing Goose integration with my Coolify-hosted Cognee instance'"
```

**Test 3: Search Cognee**
```
"Search Cognee for 'testing'"
```

**Test 4: Get Status**
```
"What's the status of my Cognee instance?"
```

### 6.4: Verify It's Working

If you see successful responses, **🎉 Congratulations!** Goose is now connected to your Coolify-hosted Cognee.

**✅ Step 6 Complete!** Your integration is working.

---

## 🐛 Troubleshooting

### Issue: "Cannot connect to Cognee"

**Check 1: Verify Cognee URL**
```bash
curl https://cognee.v1su4.com/health
```

**Check 2: Verify Configuration**
```bash
# Windows
cat $env:USERPROFILE\.config\goose\profiles.yaml

# macOS/Linux
cat ~/.config/goose/profiles.yaml
```

Make sure `COGNEE_API_URL` is set to `https://cognee.v1su4.com` (not `http://localhost:8000`).

### Issue: "Path not found"

- Make sure you used the **absolute path** (full path, not relative)
- On Windows, use forward slashes `/` or double backslashes `\\`
- Verify the path exists: `ls C:\Users\Gordo\Documents\Github\cognee\cognee-mcp` (or your path)

### Issue: "MCP server failed to start"

**Check Python and UV:**
```bash
python --version  # Should be 3.11+
uv --version      # Should show version
```

**Reinstall dependencies:**
```bash
cd cognee/cognee-mcp
uv sync --dev --all-extras --reinstall
```

### Issue: "Authentication error"

**Verify API keys are set:**
```bash
# Windows PowerShell
echo $env:LLM_API_KEY

# macOS/Linux
echo $LLM_API_KEY
```

**Test API key:**
```bash
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $LLM_API_KEY"
```

---

## 📝 Quick Reference

**Your Configuration:**
- **Cognee URL:** `https://cognee.v1su4.com`
- **Config File:** `~/.config/goose/profiles.yaml` (or `C:\Users\<You>\.config\goose\profiles.yaml`)
- **MCP Path:** `[Your absolute path]/cognee-mcp`

**Useful Commands:**
```bash
# Test Cognee
curl https://cognee.v1su4.com/health

# Start Goose
goose session start

# Check config
cat ~/.config/goose/profiles.yaml  # macOS/Linux
cat $env:USERPROFILE\.config\goose\profiles.yaml  # Windows
```

---

## 🎯 Next Steps

Now that Goose is configured, you can:

1. **Add files to Cognee:**
   ```
   "Add all Python files in my project to Cognee"
   ```

2. **Build knowledge graphs:**
   ```
   "Cognify my project files to build a knowledge graph"
   ```

3. **Search your codebase:**
   ```
   "Search Cognee for authentication patterns"
   ```

4. **Query relationships:**
   ```
   "What are the relationships between User and Auth modules?"
   ```

---

**Need Help?**
- Check [GOOSE_INTEGRATION.md](GOOSE_INTEGRATION.md) for more examples
- Review [Troubleshooting section](#-troubleshooting) above
- Check Goose logs for detailed error messages

**Happy coding with Goose and Cognee! 🚀**

