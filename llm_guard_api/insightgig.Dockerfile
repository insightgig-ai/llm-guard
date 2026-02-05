# Base image with Python 3.12
FROM python:3.12-slim

# Set working directory
WORKDIR /home/user/app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy the LLM Guard library first
COPY llm_guard/ /home/user/app/llm_guard/

# Copy the API code and config
COPY llm_guard_api/app/ /home/user/app/app/
COPY llm_guard_api/config/ /home/user/app/config/

# Copy dependency files
COPY llm_guard_api/pyproject.toml ./

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir ".[cpu]"

# Pre-download models during build (this caches them in the image)
# This avoids runtime downloads and ensures consistent deployments
RUN python -c "\
from transformers import AutoTokenizer, AutoModel; \
print('Downloading Anonymize model...'); \
AutoTokenizer.from_pretrained('Isotonic/deberta-v3-base_finetuned_ai4privacy_v2'); \
AutoModel.from_pretrained('Isotonic/deberta-v3-base_finetuned_ai4privacy_v2'); \
print('Downloading MaliciousURLs model...'); \
AutoTokenizer.from_pretrained('DunnBC22/codebert-base-Malicious_URLs'); \
AutoModel.from_pretrained('DunnBC22/codebert-base-Malicious_URLs'); \
print('All models downloaded successfully!')"

# Environment variables
ENV LOG_LEVEL=INFO
ENV LOG_JSON=true
ENV LAZY_LOAD=false
ENV SCAN_PROMPT_TIMEOUT=30
ENV SCAN_OUTPUT_TIMEOUT=30
ENV APP_WORKERS=1
ENV APP_PORT=8000

# Expose port
EXPOSE ${APP_PORT}

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:${APP_PORT}/healthz || exit 1

# Start the API
CMD ["sh", "-c", "uvicorn app.app:create_app --host=0.0.0.0 --port=${APP_PORT} --workers=${APP_WORKERS}"]