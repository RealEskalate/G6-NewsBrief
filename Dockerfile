# Use official Playwright image with Python
FROM mcr.microsoft.com/playwright/python:v1.45.0-jammy

WORKDIR /app

# Install Poetry
RUN pip install poetry

# Copy only dependency files first
COPY pyproject.toml poetry.lock* /app/

# Install dependencies system-wide
RUN poetry config virtualenvs.create false \
    && poetry install --no-dev

# Install Playwright Chromium
RUN playwright install --with-deps chromium

# Copy app code
COPY . /app

# Keep Chromium inside the image
ENV PLAYWRIGHT_BROWSERS_PATH=0

# Expose port (Render maps $PORT → container:8000)
EXPOSE 8000

# Run Gunicorn with Uvicorn workers
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "app.main:app", "--bind", "0.0.0.0:$PORT"]