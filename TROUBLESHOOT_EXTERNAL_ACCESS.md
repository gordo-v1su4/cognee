# Troubleshooting External Access Issues with Coolify Deployment

**Date: November 2024**  
**Issue**: Containers running locally on server but no external access to API endpoints

## 🔍 Step-by-Step Diagnostic Process

### Step 1: Verify Container Health

First, check if all your containers are running and healthy:

```bash
# SSH into your Coolify server
ssh user@your-server-ip

# Check running containers
docker ps

# Check container health status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check specific container logs
docker logs <container-name>
```

**Expected Result**: All containers should show "healthy" status, not just "running".

### Step 2: Test Internal Connectivity

Test if the API works internally on the server:

```bash
# Test health endpoint internally
curl http://localhost:8000/health
curl http://cognee:8000/health  # If on same docker network

# Test other endpoints
curl http://localhost:8000/status
curl http://localhost:8000/docs
```

**If this fails**: Your containers have internal issues (see Container Issues section below).  
**If this works**: The problem is external routing/networking.

### Step 3: Verify DNS Configuration

Check if your domains resolve to the correct IP:

```bash
# From your local machine (not the server)
nslookup cognee.v1su4.com
dig cognee.v1su4.com

# Should return your Coolify server's IP address
```

**Common DNS Issues**:
- Domain doesn't resolve at all → DNS not configured
- Resolves to wrong IP → DNS pointing to wrong server
- Takes a long time → DNS propagation still happening (wait 24-48 hours)

**Fix**: Update your DNS records with your domain provider:
```
Type: A
Name: cognee
Value: YOUR_COOLIFY_SERVER_IP
TTL: 300 (5 minutes)
```

### Step 4: Check Coolify Domain Configuration

In your Coolify dashboard:

1. **Go to your Cognee application**
2. **Check the Domains tab**:
   - Should show: `cognee.v1su4.com`
   - SSL status should be "✅ Active" (green checkmark)
   - If SSL shows "❌ Failed" or "⏳ Pending", this is your issue

3. **Check individual services**:
   - Main app should have `cognee.v1su4.com` configured
   - Neo4j should have `neo4j-cognee.v1su4.com` (if you want it exposed)
   - Qdrant should have `qdrant-cognee.v1su4.com` (if you want it exposed)

**Common Coolify Domain Issues**:
- Domain not added to service
- SSL certificate failed to generate
- Multiple domains conflicting
- Wrong port mapping in SERVICE_FQDN

### Step 5: Test External HTTPS Access

Try accessing your domains externally:

```bash
# Test from external machine/browser
curl -v https://cognee.v1su4.com/health
curl -v https://cognee.v1su4.com/status
```

**Analyze the response**:
- **Connection refused**: DNS issue or server firewall blocking
- **SSL/TLS handshake failed**: Certificate issue
- **404 Not Found**: Routing issue (Traefik misconfiguration)
- **502 Bad Gateway**: Backend (your app) is down/unhealthy
- **504 Gateway Timeout**: Backend is too slow to respond

### Step 6: Check Firewall and Port Access

Verify your server firewall allows HTTPS traffic:

```bash
# Check if ports are open
sudo ufw status
sudo iptables -L

# Test if port 443 is accessible externally
# From external machine:
telnet your-server-ip 443
# Or
nmap -p 443 your-server-ip
```

**Required open ports**:
- **80** (HTTP) - For Let's Encrypt validation
- **443** (HTTPS) - For your application traffic
- **22** (SSH) - For server management

### Step 7: Examine Traefik Logs

Coolify uses Traefik for reverse proxy. Check its logs:

```bash
# Find Traefik container
docker ps | grep traefik

# Check Traefik logs
docker logs coolify-traefik-<id>
docker logs -f coolify-traefik-<id>  # Follow logs in real-time

# Look for errors related to your domain
docker logs coolify-traefik-<id> 2>&1 | grep "cognee.v1su4.com"
```

**Common Traefik errors**:
- "Host not found" → Domain not properly configured
- "Service not found" → Container not healthy/reachable
- "Certificate error" → SSL certificate issues

### Step 8: Check SSL Certificate Status

```bash
# Test SSL certificate
openssl s_client -connect cognee.v1su4.com:443 -servername cognee.v1su4.com

# Check certificate expiry
echo | openssl s_client -servername cognee.v1su4.com -connect cognee.v1su4.com:443 2>/dev/null | openssl x509 -noout -dates
```

## 🛠️ Common Problems & Solutions

### Problem A: Containers Running but Unhealthy

**Symptoms**: `docker ps` shows "running" but not "healthy"

**Diagnosis**:
```bash
# Check health check logs
docker inspect <container-name> | grep -A 10 -B 10 "Health"
docker logs <container-name> | grep -i health
```

**Solutions**:
1. **Health check endpoint failing**:
   ```bash
   # Test health check manually
   curl http://localhost:8000/health
   ```
   
2. **Dependencies not ready**:
   - Check if PostgreSQL, Neo4j, Qdrant are healthy first
   - Cognee should wait for dependencies (see `depends_on` in docker-compose)

3. **Missing environment variables**:
   ```bash
   docker exec -it <cognee-container> env | grep -E "(LLM_API_KEY|POSTGRES|NEO4J)"
   ```

### Problem B: DNS Not Resolving

**Symptoms**: `nslookup cognee.v1su4.com` fails

**Solutions**:
1. **Add DNS records** at your domain provider:
   ```
   A record: cognee.v1su4.com → YOUR_SERVER_IP
   A record: neo4j-cognee.v1su4.com → YOUR_SERVER_IP
   A record: qdrant-cognee.v1su4.com → YOUR_SERVER_IP
   ```

2. **Wait for DNS propagation** (up to 48 hours)

3. **Use DNS propagation checker**: https://dnschecker.org/

### Problem C: SSL Certificate Issues

**Symptoms**: "Certificate error" or "SSL handshake failed"

**Solutions**:
1. **Regenerate certificate in Coolify**:
   - Go to Domains tab
   - Click "Regenerate Certificate"
   - Wait 2-5 minutes

2. **Check Let's Encrypt rate limits**:
   - You might have hit the rate limit (5 failures per hour)
   - Wait and try again later

3. **Verify HTTP (port 80) is accessible**:
   - Let's Encrypt needs HTTP access for validation
   - Ensure port 80 is open and not blocked

### Problem D: Wrong SERVICE_FQDN Configuration

**Symptoms**: Services accessible but on wrong domains/ports

**Check your docker-compose.yaml**:
```yaml
# CORRECT format:
cognee:
  environment:
    - SERVICE_FQDN_COGNEE_8000=cognee.v1su4.com

neo4j:
  environment:
    - SERVICE_FQDN_NEO4J_7474=neo4j-cognee.v1su4.com

# WRONG format (common mistakes):
# - SERVICE_FQDN_COGNEE=cognee.v1su4.com:8000  ❌
# - SERVICE_FQDN_COGNEE_8000=cognee.v1su4.com:8000  ❌
# - SERVICE_FQDN=cognee.v1su4.com  ❌
```

### Problem E: Firewall Blocking Traffic

**Symptoms**: Connection refused from external

**Check and fix firewall**:
```bash
# Check current rules
sudo ufw status

# Allow required ports
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp

# If using iptables directly
sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT

# Save rules
sudo iptables-save > /etc/iptables/rules.v4
```

## 🧪 Testing Script

Create this test script to verify everything works:

```bash
#!/bin/bash
# test-external-access.sh

echo "🧪 Testing Cognee External Access..."

DOMAIN="cognee.v1su4.com"
echo "Testing domain: $DOMAIN"

echo "1. DNS Resolution:"
nslookup $DOMAIN

echo -e "\n2. HTTPS Health Check:"
curl -s -o /dev/null -w "%{http_code} %{time_total}s" https://$DOMAIN/health
echo ""

echo -e "\n3. API Status:"
curl -s https://$DOMAIN/status | jq '.'

echo -e "\n4. SSL Certificate:"
echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -dates

echo -e "\n5. API Documentation:"
echo "Visit: https://$DOMAIN/docs"

echo -e "\n✅ If all tests pass, your API is accessible externally!"
```

## 📋 Debugging Checklist

Run through this checklist systematically:

- [ ] **Containers are healthy** (`docker ps` shows healthy status)
- [ ] **Health check works internally** (`curl http://localhost:8000/health`)
- [ ] **DNS resolves correctly** (`nslookup cognee.v1su4.com`)
- [ ] **Domains configured in Coolify** (Domains tab shows your domain)
- [ ] **SSL certificate active** (Green checkmark in Coolify)
- [ ] **Firewall allows 80/443** (`sudo ufw status`)
- [ ] **External HTTPS works** (`curl https://cognee.v1su4.com/health`)
- [ ] **API documentation accessible** (https://cognee.v1su4.com/docs)

## 🚨 Emergency Quick Fixes

If you need to get it working quickly:

### Option 1: Direct IP Access (Temporary)
```bash
# Access directly via server IP (bypass DNS/SSL issues)
curl http://YOUR_SERVER_IP:8000/health

# If this works, your issue is DNS/SSL
```

### Option 2: Reset SSL Certificates
```bash
# In Coolify dashboard:
# 1. Go to Domains tab
# 2. Delete the domain
# 3. Re-add the domain
# 4. Wait for new SSL certificate
```

### Option 3: Check Different Browser/Network
Sometimes it's a local DNS cache issue:
```bash
# Clear DNS cache (Windows)
ipconfig /flushdns

# Try from different network/device
# Use mobile data instead of WiFi
```

## 📞 When to Ask for Help

Contact support if:
- All containers are healthy
- DNS resolves correctly
- SSL certificate is active
- Firewall allows traffic
- But external access still fails

Provide this information:
1. Your domain name
2. Server IP address
3. `docker ps` output
4. Coolify domain configuration screenshot
5. Result of `curl -v https://yourdomain.com/health`

## 💡 Prevention Tips

1. **Always test externally** after deployment
2. **Monitor SSL certificate expiry** (Coolify handles renewal automatically)
3. **Keep DNS TTL low** (300 seconds) during initial setup
4. **Document your exact domain configuration**
5. **Set up monitoring** for external endpoints

---

**Most Common Root Cause**: Missing or incorrect domain configuration in Coolify's UI (not just in docker-compose.yaml).

The SERVICE_FQDN environment variables tell Coolify which domains to set up, but you still need to verify they're properly configured in the Coolify dashboard.