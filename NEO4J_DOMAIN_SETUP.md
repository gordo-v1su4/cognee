# 🌐 Neo4j Domain Configuration for Coolify

This guide explains how to configure `neo4j-cognee.v1su4.com` to access your Neo4j browser.

## 🔍 The Issue

The `docker-compose.yaml` has Traefik labels configured for Neo4j, but Coolify might not be recognizing them automatically. Here's how to fix it:

## ✅ Solution: Configure Domain in Coolify

### Option 1: Verify Traefik Labels Are Working (Recommended First Step)

1. **Check if DNS is configured:**
   ```bash
   nslookup neo4j-cognee.v1su4.com
   ```
   - Should resolve to your Coolify server IP
   - If not, add an A record in your DNS provider

2. **Verify the service is running:**
   - In Coolify dashboard, check that the `neo4j` container is running
   - Look at the container logs to ensure no errors

3. **Check Traefik routing:**
   - The labels in `docker-compose.yaml` should work if Coolify is managing Traefik
   - Wait 2-5 minutes after deployment for SSL certificate to be issued

### Option 2: Configure as Separate Service in Coolify (If Option 1 Doesn't Work)

If Coolify isn't recognizing the Traefik labels from docker-compose:

1. **In Coolify Dashboard:**
   - Go to your Cognee project
   - Look for **"Services"** or **"Containers"** tab
   - Find the `neo4j` service/container
   - Click on it to configure

2. **Add Domain Configuration:**
   - Look for **"Domains"** or **"Routing"** section
   - Add domain: `neo4j-cognee.v1su4.com`
   - Set port: `7474`
   - Enable HTTPS/SSL (should be automatic)

3. **Alternative: Create Separate Resource (Advanced)**
   - If Neo4j doesn't show up as configurable:
   - You might need to create a separate Coolify resource for Neo4j
   - Or modify how Coolify handles docker-compose services

### Option 3: Manual Traefik Configuration Check

If you have SSH access to your Coolify server:

1. **Check if Traefik sees the labels:**
   ```bash
   docker inspect <neo4j-container-name> | grep -A 20 Labels
   ```

2. **Check Traefik logs:**
   ```bash
   docker logs traefik | grep neo4j
   ```

3. **Verify Traefik configuration:**
   - Traefik should automatically pick up labels from containers
   - If not, check Coolify's Traefik configuration

## 🔧 Current Configuration

Your `docker-compose.yaml` has these labels for Neo4j:

```yaml
labels:
  - coolify.managed=true
  - traefik.enable=true
  - traefik.http.routers.neo4j.rule=Host(`neo4j-cognee.v1su4.com`)
  - traefik.http.routers.neo4j.entrypoints=websecure
  - traefik.http.routers.neo4j.tls.certresolver=letsencrypt
  - traefik.http.services.neo4j.loadbalancer.server.port=7474
```

These **should** work automatically if:
- ✅ DNS is configured (`neo4j-cognee.v1su4.com` → server IP)
- ✅ Coolify is managing Traefik
- ✅ SSL certificate is issued (wait 2-5 minutes)

## 🧪 Testing

After configuration:

1. **Check DNS:**
   ```bash
   nslookup neo4j-cognee.v1su4.com
   ```

2. **Test HTTPS access:**
   ```bash
   curl -I https://neo4j-cognee.v1su4.com
   ```
   - Should return HTTP 200 or 301/302 redirect

3. **Access in browser:**
   - Open: `https://neo4j-cognee.v1su4.com`
   - Login with:
     - Username: `neo4j`
     - Password: (your `NEO4J_PASSWORD` from environment variables)

## 🐛 Troubleshooting

### Domain Not Resolving

1. **Check DNS configuration:**
   - Add A record: `neo4j-cognee` → `[Your Server IP]`
   - Wait 5-10 minutes for DNS propagation

2. **Verify DNS:**
   ```bash
   dig neo4j-cognee.v1su4.com
   nslookup neo4j-cognee.v1su4.com
   ```

### SSL Certificate Not Issued

1. **Wait 2-5 minutes** after deployment
2. **Check Coolify logs** for certificate errors
3. **Verify DNS** is pointing to correct IP
4. **Ensure ports 80 and 443** are accessible

### 404 Not Found or Connection Refused

1. **Check Neo4j container is running:**
   ```bash
   docker ps | grep neo4j
   ```

2. **Check Traefik routing:**
   - Verify labels are applied: `docker inspect <neo4j-container> | grep traefik`
   - Check Traefik logs: `docker logs traefik`

3. **Verify port mapping:**
   - Neo4j should be listening on port 7474
   - Traefik should route to that port

### Neo4j Browser Shows Wrong URL

The Neo4j browser might try to connect to `http://localhost:7474` instead of your domain. The updated `docker-compose.yaml` includes:

```yaml
NEO4J_server_browser__post__connect__cmd: play https://neo4j-cognee.v1su4.com
NEO4J_server_browser__remote__content__hostname__whitelist: neo4j-cognee.v1su4.com
```

After updating docker-compose.yaml:
1. **Redeploy in Coolify** (or push changes and auto-deploy)
2. **Restart Neo4j container** if needed

## 📝 Quick Checklist

- [ ] DNS A record added: `neo4j-cognee.v1su4.com` → server IP
- [ ] DNS verified: `nslookup neo4j-cognee.v1su4.com` works
- [ ] Neo4j container is running in Coolify
- [ ] Traefik labels are in docker-compose.yaml (they are ✅)
- [ ] SSL certificate issued (wait 2-5 minutes)
- [ ] Can access: `https://neo4j-cognee.v1su4.com`
- [ ] Can login with Neo4j credentials

## 🆘 Still Not Working?

1. **Check Coolify documentation** for docker-compose domain configuration
2. **Review Coolify logs** for routing errors
3. **Check Traefik dashboard** (if accessible) to see registered routes
4. **Consider creating separate Coolify resource** for Neo4j if needed

## 💡 Alternative: Access via Port Forwarding (Temporary)

If domain configuration isn't working, you can temporarily access Neo4j via port forwarding:

1. **SSH into your Coolify server**
2. **Port forward:**
   ```bash
   ssh -L 7474:localhost:7474 user@your-server
   ```
3. **Access:** `http://localhost:7474`

But this is **not recommended for production** - use the domain configuration instead.

