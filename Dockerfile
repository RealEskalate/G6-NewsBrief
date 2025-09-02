# Use an official Python runtime with Playwright dependencies
FROM mcr.microsoft.com/playwright/python:v1.45.0-jammy

# Set working directory
WORKDIR /app

# Install Poetry
RUN pip install poetry

# Copy Poetry files
COPY pyproject.toml poetry.lock* /app/

# Install dependencies
RUN poetry config virtualenvs.create false && poetry install --no-dev

# Install Playwright browsers
RUN playwright install --with-deps chromium

# Copy the rest of the application code
COPY . /app

# Set environment variable for Playwright
ENV PLAYWRIGHT_BROWSERS_PATH=0

# Expose the port Render will use
EXPOSE $PORT

# Start the application
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "app.main:app", "--bind", "0.0.0.0:$PORT"]