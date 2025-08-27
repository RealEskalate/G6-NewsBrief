from fastapi import FastAPI
from app.routers import news
from app.database import engine, Base  # Optional DB
from dotenv import load_dotenv

load_dotenv()  # Load .env variables including NEWSAPI_KEY, TELEGRAM_API_ID, etc.

app = FastAPI(title="AI News Brief API", version="1.0")

# Optional: Create DB tables
Base.metadata.create_all(bind=engine)

app.include_router(news.router, prefix="/api/v1")