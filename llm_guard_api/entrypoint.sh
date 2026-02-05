#!/bin/bash

APP_WORKERS=${APP_WORKERS:-1}
APP_PORT=${APP_PORT:-8000}
CONFIG_FILE=${CONFIG_FILE:-./config/scanners.yml}

# Uvicorn with workers
uvicorn app.app:create_app --host=0.0.0.0 --port="$APP_PORT" --workers="$APP_WORKERS" --forwarded-allow-ips="*" --proxy-headers --timeout-keep-alive="2"
