# Cognee on Coolify

This directory contains a minimal repository layout for self-hosting [Cognee](https://docs.cognee.ai/getting-started/introduction) through [Coolify](https://coolify.io/). Copy these files into a fresh Git repository (or fork this project) and import it as a Docker Compose stack inside Coolify.

## Repository layout

```
.
├── .env.example          # Template of environment variables Coolify should inject
├── coolify.json          # Manifest that Coolify uses for marketplace deployments
├── docker-compose.yml    # Production-ready services for Cognee and dependencies
└── README.md             # This guide
```

The repository is intentionally lightweight so that you can fork it, adjust the Docker image tags, or replace managed services with cloud offerings.

## Quick start

1. **Create a new Git repository** on your Git hosting provider and copy the contents of this directory into the new repo.
2. **Ensure you're on the deployment branch** you want Coolify to track. Run `git status -sb` to confirm and create one with `git checkout -b coolify` if needed.
3. **Duplicate the `.env.example` file** as `.env` and populate the variables with your production secrets.
4. **Commit and push the repository** so GitHub (or your provider) runs its Actions/CI workflows on that branch. Verify the latest run on the **Actions** tab finishes successfully before deploying.
5. **Import the branch into Coolify** as a Docker Compose project. You can either:
   - Use *Deploy > Add Resource > Docker Compose* and point Coolify at the repository URL, or
   - Publish the repository as a Coolify marketplace template using `deploy/coolify/coolify.json`.
6. **Configure domains and ports** inside the Coolify dashboard. At minimum expose port 3000 for the Cognee API/UI. Optionally publish Neo4j (7474/7687) and Qdrant (6333) if you want direct access.
7. **Deploy the stack**. Coolify will provision the containers, networks, and persistent volumes. Once the health checks pass you can access Cognee at the configured domain.

## Environment variables

The `.env.example` template captures the minimum configuration to run Cognee with its default providers:

- **Database credentials**: `POSTGRES_PASSWORD` is mandatory. Adjust the database name/user if desired.
- **Graph database**: `NEO4J_PASSWORD` must be set for Neo4j authentication.
- **LLM & embeddings**: Provide API keys for your LLM (`LLM_API_KEY`) and embedding provider (`EMBEDDING_API_KEY`). Defaults target OpenAI but you can change the providers/models.
- **Vector database**: Qdrant works out-of-the-box with anonymous access, but set `QDRANT_API_KEY` if your environment requires one.
- **Application tuning**: Override `LOG_LEVEL`, `COGNEE_ENV`, or add additional Cognee environment variables as needed.

> ℹ️ **Tip:** Coolify stores secrets securely. After importing, edit the Docker Compose resource in the UI to map each variable to a Coolify secret.

## Customisations

- **Alternative images**: Replace `gordov1su4/cognee-api:latest` with a pinned release or your own build.
- **Managed databases**: Comment out Postgres/Neo4j/Qdrant services and update connection URLs if you rely on managed providers.
- **Scaling**: For multi-instance deployments, add a Traefik proxy service and scale the `cognee` service using the Coolify UI.

## Maintenance checklist

- Review upstream Cognee release notes for environment variable changes.
- Rotate database and API credentials regularly.
- Monitor container health via Coolify. All services expose HTTP health checks that the platform can observe.

For more background on Cognee concepts and configuration, read the official [Getting Started guide](https://docs.cognee.ai/getting-started/introduction).
