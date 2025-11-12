# 🔧 Neo4j "No Available Server" Troubleshooting

## The Error

When accessing `https://neo4j-cognee.v1su4.com`, you see: **"No available server"**

## Common Causes

### 1. WebSocket Connection Issue

Neo4j browser uses WebSockets, which need proper proxy configuration.

**Current Fix Applied:**
- Added Traefik middleware with `X-Forwarded-Proto` and `X-Forwarded-Host` headers
- These tell Neo4j it's behind HTTPS proxy

### 2. Neo4j Container Not Running

**Check in Coolify:**
- Go to your Cognee project
- Verify `neo4j` container shows "Running" status
- Check logs for errors

### 3. Traefik Routing Issue

**Verify Traefik sees Neo4j:**
```bash
# SSH into your Coolify server
docker ps | grep neo4j
docker inspect <neo4j-container-name> | grep -A 10 Labels
```

**Check Traefik logs:**
```bash
docker logs traefik | grep neo4j
```

### 4. SSL Certificate Not Issued

**Wait 2-5 minutes** after deployment for Let's Encrypt certificate.

**Check certificate:**
```bash
curl -I https://neo4j-cognee.v1su4.com
```

### 5. Neo4j Browser WebSocket Configuration

Neo4j browser might need explicit WebSocket configuration. Try accessing directly:

**Test HTTP endpoint:**
```bash
curl https://neo4j-cognee.v1su4.com
```

Should return Neo4j HTML page.

## Step-by-Step Fix

### Step 1: Verify Container Status

In Coolify dashboard:
1. Go to your Cognee project
2. Find `neo4j` service
3. Check status is "Running"
4. View logs - should see "Started" message

### Step 2: Test Direct Access

```bash
# Test if Neo4j HTTP is accessible
curl -I https://neo4j-cognee.v1su4.com

# Should return HTTP 200 or 301/302
```

### Step 3: Check Traefik Configuration

The current `docker-compose.yaml` includes:
- Traefik labels for routing
- Middleware for proxy headers
- WebSocket support

**Verify labels are applied:**
```bash
docker inspect <neo4j-container> | grep traefik
```

### Step 4: Test Browser Connection

1. Open: `https://neo4j-cognee.v1su4.com`
2. You should see Neo4j login page
3. Login with:
   - Username: `neo4j`
   - Password: (your `NEO4J_PASSWORD`)

### Step 5: If Still Not Working

**Option A: Check Neo4j Logs**

In Coolify, view Neo4j container logs:
- Look for WebSocket errors
- Look for connection errors
- Look for proxy-related warnings

**Option B: Test Without Proxy**

Temporarily test direct access (if you have SSH):
```bash
# Port forward
ssh -L 7474:localhost:7474 user@your-server

# Then access: http://localhost:7474
```

If this works, the issue is Traefik configuration.

**Option C: Simplify Configuration**

Try removing middleware temporarily to test basic routing:

```yaml
labels:
  - coolify.managed=true
  - traefik.enable=true
  - traefik.http.routers.neo4j.rule=Host(`neo4j-cognee.v1su4.com`)
  - traefik.http.routers.neo4j.entrypoints=websecure
  - traefik.http.routers.neo4j.tls.certresolver=letsencrypt
  - traefik.http.services.neo4j.loadbalancer.server.port=7474
```

## Current Configuration

Your `docker-compose.yaml` now includes:

```yaml
labels:
  - traefik.http.routers.neo4j.middlewares=neo4j-headers
  - traefik.http.middlewares.neo4j-headers.headers.customrequestheaders.X-Forwarded-Proto=https
  - traefik.http.middlewares.neo4j-headers.headers.customrequestheaders.X-Forwarded-Host=neo4j-cognee.v1su4.com
```

This tells Neo4j:
- It's behind HTTPS proxy
- The public hostname is `neo4j-cognee.v1su4.com`

## Next Steps

1. **Redeploy in Coolify** with updated configuration
2. **Wait 2-5 minutes** for SSL certificate
3. **Test access**: `https://neo4j-cognee.v1su4.com`
4. **Check logs** if still not working

## Alternative: Access via Port Forwarding

If Traefik routing isn't working, you can temporarily access Neo4j:

```bash
# SSH into server
ssh user@your-server

# Port forward
ssh -L 7474:localhost:7474 user@your-server

# Then access: http://localhost:7474
```

**Note:** This is temporary - fix Traefik routing for production.

## Still Having Issues?

1. **Check Coolify logs** for Traefik errors
2. **Verify wildcard DNS** is working: `nslookup test.v1su4.com`
3. **Compare with Qdrant** - if Qdrant works, Neo4j should too
4. **Check Neo4j version** - ensure compatibility with Traefik

## Quick Test Commands

```bash
# Test DNS
nslookup neo4j-cognee.v1su4.com

# Test HTTPS
curl -I https://neo4j-cognee.v1su4.com

# Test container
docker ps | grep neo4j

# Test Traefik routing
docker logs traefik | grep neo4j
```

