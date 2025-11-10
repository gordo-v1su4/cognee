# Windows Setup Guide for Cognee

Special instructions for setting up Cognee on Windows systems.

## Prerequisites for Windows

### 1. Install Docker Desktop

Download and install [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)

**Requirements:**
- Windows 10/11 Pro, Enterprise, or Education (64-bit)
- WSL 2 enabled
- Hyper-V enabled (or WSL 2 backend)

**Installation steps:**
```powershell
# Download Docker Desktop installer
# Run the installer
# Restart your computer when prompted
```

**Verify installation:**
```powershell
docker --version
docker-compose --version
```

### 2. Install Git Bash

Download from [Git for Windows](https://gitforwindows.org/)

Git Bash provides a Unix-like shell environment on Windows, which is needed for the shell scripts.

### 3. Install WSL 2 (Recommended)

```powershell
# Run in PowerShell as Administrator
wsl --install
wsl --set-default-version 2
```

Restart your computer after installation.

## Setup Instructions

### Step 1: Clone or Create Project

```powershell
# In PowerShell or Command Prompt
cd C:\Users\YourUsername\Documents
mkdir cognee
cd cognee
```

### Step 2: Create Environment File

```powershell
# Copy the example file
copy env.example .env

# Edit with Notepad
notepad .env
```

**Update these values:**
```env
LLM_API_KEY=your_openai_api_key_here
EMBEDDING_API_KEY=your_openai_api_key_here
POSTGRES_PASSWORD=your_secure_password
NEO4J_PASSWORD=your_secure_password
```

### Step 3: Start Services

#### Option A: Using PowerShell

```powershell
# Start Docker Desktop first, then run:
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

#### Option B: Using Git Bash

```bash
# Open Git Bash in your project directory
./quickstart.sh
```

### Step 4: Verify Installation

```powershell
# Test the API
curl.exe http://localhost:8000/health

# Or use PowerShell's Invoke-WebRequest
Invoke-WebRequest -Uri http://localhost:8000/health
```

**Expected response:**
```json
{"status": "healthy", "service": "cognee-api"}
```

### Step 5: Access Services

Open in your browser:
- **API Docs**: http://localhost:8000/docs
- **Neo4j Browser**: http://localhost:7474
- **Qdrant Dashboard**: http://localhost:6333/dashboard

## Windows-Specific Commands

### PowerShell Equivalents

| Bash Command | PowerShell Command |
|--------------|-------------------|
| `ls -la` | `Get-ChildItem` or `dir` |
| `cat file.txt` | `Get-Content file.txt` |
| `tail -f logs` | `Get-Content logs -Tail 10 -Wait` |
| `curl` | `Invoke-WebRequest` or `curl.exe` |
| `chmod +x` | Not needed on Windows |

### Docker Commands (Same on Windows)

```powershell
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f cognee

# Check status
docker-compose ps

# Restart service
docker-compose restart cognee

# Remove everything
docker-compose down -v
```

## Testing the API (PowerShell)

### Add Data

```powershell
$body = @{
    data = "Artificial Intelligence is transforming software development"
    dataset_name = "test"
} | ConvertTo-Json

Invoke-WebRequest -Uri http://localhost:8000/add `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

### Cognify

```powershell
$body = @{
    dataset_name = "test"
} | ConvertTo-Json

Invoke-WebRequest -Uri http://localhost:8000/cognify `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

### Search

```powershell
$body = @{
    query = "What is AI?"
    mode = "default"
} | ConvertTo-Json

Invoke-WebRequest -Uri http://localhost:8000/search `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

## Goose Integration on Windows

### Install UV

In PowerShell as Administrator:

```powershell
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

Restart PowerShell after installation.

### Install Goose

```powershell
# Download from GitHub releases or use Chocolatey
choco install goose

# Or use the installer from:
# https://github.com/block/goose/releases
```

### Setup Cognee MCP

```powershell
# Clone repository
git clone https://github.com/topoteretes/cognee.git
cd cognee\cognee-mcp

# Install dependencies
uv sync --dev --all-extras --reinstall
```

### Configure Goose

Edit `C:\Users\YourUsername\.config\goose\profiles.yaml`:

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
        - C:\Users\YourUsername\path\to\cognee-mcp  # Use Windows path
        - run
        - python
        - src/server.py
      env:
        COGNEE_API_URL: http://localhost:8000
        LLM_API_KEY: ${LLM_API_KEY}
        EMBEDDING_API_KEY: ${EMBEDDING_API_KEY}
```

**Important:** Use Windows-style paths with backslashes or forward slashes (both work).

### Set Environment Variables

In PowerShell:

```powershell
# For current session
$env:LLM_API_KEY = "your_openai_api_key"
$env:EMBEDDING_API_KEY = "your_openai_api_key"

# For permanent (user-level)
[System.Environment]::SetEnvironmentVariable('LLM_API_KEY', 'your_key', 'User')
[System.Environment]::SetEnvironmentVariable('EMBEDDING_API_KEY', 'your_key', 'User')
```

### Start Goose

```powershell
goose session start
```

## Troubleshooting Windows Issues

### Docker Desktop Not Starting

1. **Enable WSL 2:**
   ```powershell
   wsl --install
   wsl --set-default-version 2
   ```

2. **Enable Hyper-V** (if using Hyper-V backend):
   - Open "Turn Windows features on or off"
   - Enable "Hyper-V"
   - Restart computer

3. **Check Docker Desktop settings:**
   - Open Docker Desktop
   - Settings → General
   - Ensure "Use WSL 2 based engine" is checked

### Port Already in Use

```powershell
# Find what's using the port
netstat -ano | findstr :8000

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F
```

### Permission Issues

1. **Run as Administrator:**
   - Right-click PowerShell
   - Select "Run as Administrator"

2. **Check Docker permissions:**
   - Add your user to "docker-users" group
   - Restart computer

### WSL Integration Issues

```powershell
# Reset WSL
wsl --shutdown
wsl --unregister Ubuntu
wsl --install -d Ubuntu
```

### Path Issues in Git Bash

If scripts can't find files:

```bash
# Convert Windows path to Unix-style
cd /c/Users/YourUsername/Documents/cognee
```

### Line Ending Issues

Git Bash might have issues with Windows line endings:

```bash
# Convert line endings
dos2unix quickstart.sh
dos2unix healthcheck.sh

# Or configure Git
git config --global core.autocrlf true
```

## Health Check Script for PowerShell

Save as `healthcheck.ps1`:

```powershell
Write-Host "🏥 Cognee Health Check" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan

function Test-Service {
    param($Name, $Url)
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $Name is healthy" -ForegroundColor Green
            return $true
        }
    } catch {
        Write-Host "❌ $Name is not responding" -ForegroundColor Red
        return $false
    }
}

$allHealthy = $true

Write-Host "`nChecking Cognee API..."
$allHealthy = $allHealthy -and (Test-Service "Cognee API" "http://localhost:8000/health")

Write-Host "`nChecking Neo4j..."
$allHealthy = $allHealthy -and (Test-Service "Neo4j" "http://localhost:7474")

Write-Host "`nChecking Qdrant..."
$allHealthy = $allHealthy -and (Test-Service "Qdrant" "http://localhost:6333/health")

if ($allHealthy) {
    Write-Host "`n🎉 All services are healthy!" -ForegroundColor Green
} else {
    Write-Host "`n❌ Some services are unhealthy" -ForegroundColor Red
    Write-Host "Run: docker-compose logs -f" -ForegroundColor Yellow
}
```

Run with:
```powershell
.\healthcheck.ps1
```

## Backup Script for PowerShell

Save as `backup.ps1`:

```powershell
$date = Get-Date -Format "yyyyMMdd"

Write-Host "📦 Backing up Cognee data..." -ForegroundColor Cyan

# PostgreSQL backup
docker-compose exec -T postgres pg_dump -U cognee cognee > "backup-$date.sql"
Write-Host "✅ PostgreSQL backed up to backup-$date.sql" -ForegroundColor Green

# Neo4j backup
docker-compose exec neo4j neo4j-admin dump --database=neo4j --to=/tmp/backup.dump
docker cp cognee-neo4j:/tmp/backup.dump "neo4j-backup-$date.dump"
Write-Host "✅ Neo4j backed up to neo4j-backup-$date.dump" -ForegroundColor Green

Write-Host "`n🎉 Backup complete!" -ForegroundColor Green
```

## Windows Firewall Configuration

If you need to access from other machines:

```powershell
# Run as Administrator
New-NetFirewallRule -DisplayName "Cognee API" -Direction Inbound -LocalPort 8000 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Neo4j HTTP" -Direction Inbound -LocalPort 7474 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Neo4j Bolt" -Direction Inbound -LocalPort 7687 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Qdrant" -Direction Inbound -LocalPort 6333 -Protocol TCP -Action Allow
```

## Additional Resources

- [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/)
- [WSL 2 Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [Git Bash Guide](https://gitforwindows.org/)
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)

## Quick Reference

### Start/Stop Commands

```powershell
# Start
docker-compose up -d

# Stop
docker-compose down

# Restart
docker-compose restart

# Logs
docker-compose logs -f

# Status
docker-compose ps
```

### Common Issues

| Issue | Solution |
|-------|----------|
| Port 8000 in use | `netstat -ano \| findstr :8000` then kill process |
| Docker won't start | Enable WSL 2 or Hyper-V |
| Permission denied | Run PowerShell as Administrator |
| Can't access services | Check Windows Firewall |
| Scripts won't run | Use Git Bash or convert line endings |

---

**Need Help?**  
Check [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for more commands!

