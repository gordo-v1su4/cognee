# Multi-stage build for Cognee self-hosted deployment
FROM python:3.11-slim AS base

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      python3-dev \
      curl \
      git \
      ca-certificates \
      perl \
    && rm -rf /var/lib/apt/lists/*

# Install uv for faster dependency installation
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies using uv with retries
RUN uv pip install --system --no-cache -r requirements.txt || \
    uv pip install --system --no-cache -r requirements.txt

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p /app/data /app/logs

# Create non-root user for better security
RUN useradd -m -u 1000 cognee && \
    chown -R cognee:cognee /app

# Switch to non-root user
USER cognee

# Expose port (default Cognee API port)
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run the application
# Use reload only in development, production should not use --reload
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

