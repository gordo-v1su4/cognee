# Fix Port 8000 Conflict with Coolify

**Issue**: Cognee API was trying to use port 8000, which conflicts with Coolify's dashboard running on the same port.

**Solution**: Changed Cognee to use port 3000 instead.

## Files Modified

### 1. docker-compose.yaml
```yaml
# CHANGED FROM:
- SERVICE_FQDN_COGNEE_8000=cognee.v1su4.com

# CHANGED TO:
- SERVICE_FQDN_COGNEE_3000=cognee.v1su4.com

# Also updated healthcheck:
test: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1"]
```

### 2. main.py
```python
# CHANGED FROM:
port = int(os.getenv("COGNEE_PORT", 8000))

# CHANGED TO:
port = int(os.getenv("COGNEE_PORT", 3000))
```

### 3. Dockerfile
```dockerfile
# CHANGED FROM:
EXPOSE 8000
HEALTHCHECK CMD curl -f http://localhost:8000/health || exit 1
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

# CHANGED TO:
EXPOSE 3000
HEALTHCHECK CMD curl -f http://localhost:3000/health || exit 1
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]
```

## Deployment Steps

### 1. Commit and Push Changes
```bash
git add .
git commit -m "Fix port conflict: Change Cognee from port 8000 to 3000"
git push origin main
```

### 2. Redeploy in Coolify
1. Go to Coolify dashboard
2. Find your Cognee project
3. Click "Redeploy" or "Deploy"
4. Wait for containers to rebuild and start

### 3. Update Domain Configuration (if needed)
In Coolify dashboard:
1. Go to Domains tab
2. Verify `cognee.v1su4.com` points to port 3000
3. If not, update the configuration

### 4. Test the Fix

**Internal test:**
```bash
# Should work on new port
curl http://localhost:3000/health
docker exec -it <cognee-container> curl http://localhost:3000/health
```

**External test:**
```bash
# Should work after Coolify routing update
curl https://cognee.v1su4.com/health
```

## Expected Results

After deployment:
- ✅ Port 8000 remains free for Coolify dashboard
- ✅ Cognee API runs on port 3000 internally
- ✅ External access via https://cognee.v1su4.com works
- ✅ Container shows "healthy" status
- ✅ No more port conflicts

## Verification Commands

```bash
# Check container status (should be healthy now)
docker ps --format "table {{.Names}}\t{{.Status}}"

# Test internal API
curl http://localhost:3000/health

# Test external API
curl https://cognee.v1su4.com/health

# Check API documentation
curl https://cognee.v1su4.com/docs
```

## Troubleshooting

If external access still doesn't work after deployment:

1. **Check Coolify domain configuration**:
   - Ensure `cognee.v1su4.com` is configured
   - Verify SSL certificate is active (green checkmark)
   - Make sure it points to the cognee service on port 3000

2. **Check container logs**:
   ```bash
   docker logs <cognee-container>
   ```

3. **Verify no port conflicts**:
   ```bash
   netstat -tlnp | grep 3000  # Should show your Cognee API
   netstat -tlnp | grep 8000  # Should show Coolify only
   ```

## Environment Variables (Optional)

You can also set this environment variable in Coolify to be explicit:

```bash
COGNEE_PORT=3000
```

This ensures the port is always 3000 regardless of the default in main.py.

---

**Summary**: This fix resolves the port conflict by moving Cognee API from port 8000 (used by Coolify) to port 3000, allowing both services to coexist properly.