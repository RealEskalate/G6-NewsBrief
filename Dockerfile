# Use official Playwright image with Python v1.55.0
FROM mcr.microsoft.com/playwright/python:v1.55.0-jammy

# Set working directory
WORKDIR /app

# Copy requirements.txt first (to leverage Docker cache)
COPY requirements.txt /app/

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install Playwright Chromium browser
RUN playwright install --with-deps chromium

# Copy the rest of the application code
COPY . /app

# Expose a default port (Docker requires a number)
EXPOSE 8000

# Start Gunicorn with Uvicorn workers using Render's injected $PORT
CMD gunicorn -k uvicorn.workers.UvicornWorker app.main:app \
    --bind 0.0.0.0:$PORT \
    --timeout 120 \
    --workers 2 \
    --threads 4
