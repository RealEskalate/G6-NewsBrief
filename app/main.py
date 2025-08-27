from fastapi import FastAPI
from app.routers import news
from dotenv import load_dotenv

load_dotenv()  # Load .env variables including NEWSAPI_KEY, TELEGRAM_API_ID, etc.

app = FastAPI(title="AI News Brief API", version="1.0")

app.include_router(news.router, prefix="/api/v1")