# Deploying Cognee with Coolify

This guide explains how to turn the [`deploy/coolify`](../../deploy/coolify/README.md) scaffold into a standalone repository that Coolify can deploy.

## 1. Prepare a repository

1. Create a new empty repository on GitHub, GitLab, or another Git provider.
2. Copy the contents of `deploy/coolify/` into the new repo root.
3. Check that you are working on the branch you intend to deploy (for example a `coolify` or `production` branch) by running `git status -sb`. Switch branches with `git checkout -b <branch>` if necessary.
4. Commit the files and push to your remote. The first push of a new branch automatically triggers the GitHub Actions workflows included with the repository; subsequent pushes will queue new runs.
5. Confirm the workflows succeeded before proceeding to deployment. From the repository page open **Actions** → select your branch → ensure the latest run completed without errors.

## 2. Configure secrets

1. Duplicate `.env.example` to `.env` and set strong values for:
   - `POSTGRES_PASSWORD`
   - `NEO4J_PASSWORD`
   - `LLM_API_KEY`
   - `EMBEDDING_API_KEY`
2. Add any optional overrides you need (for example custom model names or a Qdrant API key).
3. Store the values as Coolify secrets when importing the repository.

## 3. Import into Coolify

1. In the Coolify dashboard choose **Deploy → Add Resource → Docker Compose**.
2. Provide the Git repository URL and branch.
3. If you want this stack available in the marketplace, include `coolify.json` in the repository root and publish it via **Settings → Marketplace Templates**.

## 4. Set domains and networking

- Expose the Cognee service on port `3000` via either a custom domain or an internal endpoint.
- Optionally publish Neo4j (`7474`, `7687`) and Qdrant (`6333`) for direct admin access.
- Coolify creates volumes automatically for persistent data.

## 5. Deploy and verify

1. Trigger a deployment from Coolify.
2. Monitor the logs until all health checks are green.
3. Open the Cognee URL and complete any first-run configuration.

## Troubleshooting tips

- Ensure the LLM and embedding API keys are valid before deploying—Cognee refuses to start without them.
- Health checks use `wget`. If your base image is different, adjust the commands in `docker-compose.yml`.
- You can swap in managed services by removing the local Postgres/Neo4j/Qdrant services and updating the connection URLs in the environment section.

Refer to the [Cognee Getting Started documentation](https://docs.cognee.ai/getting-started/introduction) for product-level configuration details.
