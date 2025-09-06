from fastapi import FastAPI
from app.routers import news
from apscheduler.schedulers.asyncio import AsyncIOScheduler

from dotenv import load_dotenv

load_dotenv()  # Load .env variables including NEWSAPI_KEY, TELEGRAM_API_ID, etc.

app = FastAPI(title="AI News Brief API", version="1.0")
scheduler = AsyncIOScheduler()

@app.get("/")
async def root():
    return {"message": "Welcome to the News Service Provider Home!"}

def trigger_crawler():
    import asyncio
    from app.services.crawler import scheduled_crawl

    print("Triggering scheduled crawl...")  
    asyncio.run(news.gather_news(
        crawl_req = {
            urls: [], # type: ignore
            query: "" # type: ignore
        },
        api_req = {
            query: "Ethiopia, Africa" # type: ignore
        },
    ))

@app.on_event("startup")
def start_scheduler():
    # Run every 2 hours
    scheduler.add_job(trigger_crawler, "interval", hours=2)
    scheduler.start()

    print("Scheduler started")

@app.on_event("shutdown")
def shutdown_scheduler():
    scheduler.shutdown()
    print("Scheduler shut down")

app.include_router(news.router, prefix="/api/v1")