# Contributing to Cognee Self-Hosted

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## How to Contribute

### Reporting Issues

If you encounter any problems with the deployment:

1. Check existing issues first
2. Include detailed information:
   - Operating system and version
   - Docker and Docker Compose versions
   - Error messages and logs
   - Steps to reproduce

### Suggesting Enhancements

Have ideas for improving the deployment? Great! Please:

1. Check if the enhancement is already suggested
2. Describe the feature clearly
3. Explain the use case and benefits
4. Consider implementation complexity

### Pull Requests

1. **Fork the repository**

2. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes:**
   - Follow existing code style
   - Update documentation if needed
   - Test your changes thoroughly

4. **Commit your changes:**
   ```bash
   git commit -m "Add: clear description of changes"
   ```
   
   Use conventional commits:
   - `Add:` for new features
   - `Fix:` for bug fixes
   - `Update:` for updates to existing features
   - `Docs:` for documentation changes

5. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request:**
   - Describe your changes clearly
   - Reference any related issues
   - Include testing steps

## Development Setup

### Testing Locally

```bash
# Start services
docker-compose up -d

# Run health checks
./healthcheck.sh

# Test API endpoints
curl http://localhost:8000/health
curl http://localhost:8000/status
```

### Testing Configuration Changes

```bash
# Validate docker-compose syntax
docker-compose config

# Check for errors without starting
docker-compose up --no-start
```

## Documentation

When making changes, please update:

- `README.md` - for user-facing documentation
- `DEPLOYMENT.md` - for deployment-specific instructions
- `env.example` - for new environment variables
- Code comments - for implementation details

## Code Style

### Shell Scripts

- Use bash shebang: `#!/bin/bash`
- Include error handling: `set -e`
- Add comments for complex logic
- Test on both Linux and macOS if possible

### Docker

- Use official images when possible
- Include health checks
- Set appropriate resource limits
- Use multi-stage builds when beneficial

### Python

- Follow PEP 8 style guide
- Use type hints
- Include docstrings
- Handle errors appropriately

## Testing Guidelines

Before submitting:

1. **Test the full deployment:**
   ```bash
   docker-compose down -v
   docker-compose up -d
   ./healthcheck.sh
   ```

2. **Test API endpoints:**
   ```bash
   # Add data
   curl -X POST http://localhost:8000/add \
     -H "Content-Type: application/json" \
     -d '{"data": "test data"}'
   
   # Cognify
   curl -X POST http://localhost:8000/cognify
   
   # Search
   curl -X POST http://localhost:8000/search \
     -H "Content-Type: application/json" \
     -d '{"query": "test"}'
   ```

3. **Test with Coolify** (if possible):
   - Deploy to a test Coolify instance
   - Verify environment variables work
   - Test domain configuration

## Community

- Be respectful and constructive
- Help others when possible
- Share your use cases and experiences
- Provide feedback on documentation

## Questions?

- Open an issue for questions
- Join discussions in existing issues
- Check documentation first

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

Thank you for contributing! 🎉

