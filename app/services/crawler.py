import asyncio
import chromadb
from typing import List, Dict
from app.services.rss_crawler import crawl_rss_feeds
from app.services.homepage_crawler import crawl_homepages
from app.services.daily_scoop_crawler import crawl_daily_scoop
from app.services.article_extractor import extract_article_content
from app.services.vector_db import VectorDBService
import logging

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

async def crawl_news(urls: List[str], query: str, vector_db: chromadb.Client = None) -> List[Dict]:
    """Crawl news articles from URLs, RSS feeds, and daily-scoop, optionally storing in ChromaDB."""
    async with AsyncWebCrawler(verbose=True, playwright_stealth=True) as crawler:
        semaphore = asyncio.Semaphore(3)
        news_data = []

        # Define sources
        sources = [
            {"name": "addisstandard", "feed": "https://addisstandard.com/feed/", "homepage": "https://addisstandard.com/"},
            {"name": "fanatv", "feed": "https://www.fanabc.com/feed/", "homepage": "https://www.fanabc.com/"},
            {"name": "Ethiopian Reporter", "feed": "https://ethiopianreporter.com/feed/", "homepage": "https://ethiopianreporter.com/"},
            {"name": "Oromia Broadcasting Network", "feed": "https://obn.com.et/feed/", "homepage": "https://obn.com.et/"},
            {"name": "EHPEA", "feed": "https://ehpea.org/feed/", "homepage": "https://ehpea.org/"}
        ]

        # Step 1: Crawl RSS feeds
        rss_articles = await crawl_rss_feeds(sources, query)

        # Step 2: Crawl homepages
        scrape_articles = await crawl_homepages(crawler, sources, urls, query, semaphore)

        # Step 3: Crawl Addis Standard daily-scoop
        if "https://addisstandard.com" in urls:
            daily_scoop_items = await crawl_daily_scoop(crawler, semaphore, query)
            scrape_articles.extend(daily_scoop_items)

        # Step 4: Combine and deduplicate articles
        all_articles = []
        seen_links = set()
        # Prioritize "Broken Promise" article
        for article in scrape_articles:
            if "broken-promise" in article["source_url"].lower():
                all_articles.append(article)
                seen_links.add(article["source_url"])
        for article in rss_articles:
            if article["source_url"] not in seen_links:
                all_articles.append(article)
                seen_links.add(article["source_url"])
        for article in scrape_articles:
            if article["source_url"] not in seen_links:
                all_articles.append(article)
                seen_links.add(article["source_url"])

        # Step 5: Fetch full content for articles
        tasks = []
        for article in all_articles[:50]:
            if len(article["content"]) < 200 or not article["content"]:
                tasks.append(extract_article_content(crawler, article["source_url"], article["title"], article["source_site"], semaphore, query))
            else:
                tasks.append(asyncio.ensure_future(asyncio.sleep(0, result=article)))
        
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Step 6: Process results
        for article, result in zip(all_articles, results):
            if isinstance(result, Exception):
                logger.error(f"Error crawling {article['source_url']}: {result}")
                continue
            if not result:
                logger.warning(f"No data extracted for {article['source_url']}")
                continue
            if query.lower() in result["title"].lower() or query.lower() in result["content"].lower():
                news_data.append(result)
            if len(news_data) >= 20:
                break

        # Step 7: Store in ChromaDB if vector_db is provided
        if vector_db:
            try:
                vector_service = VectorDBService(vector_db)
                for item in news_data:
                    vector_service.add_article(item)
                logger.info(f"Stored {len(news_data)} articles in ChromaDB")
            except Exception as e:
                logger.error(f"Failed to store in ChromaDB: {e}")

        return news_data

from crawl4ai import AsyncWebCrawler