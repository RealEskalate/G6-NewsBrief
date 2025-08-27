import asyncio
from crawl4ai import AsyncWebCrawler
from bs4 import BeautifulSoup
from datetime import datetime, timezone
import logging
import re
from typing import List, Dict
import uuid

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

async def crawl_daily_scoop(crawler: AsyncWebCrawler, semaphore, query: str) -> List[Dict]:
    """Crawl Addis Standard daily-scoop page to extract news items."""
    async with semaphore:
        try:
            result = await crawler.arun(
                url="https://addisstandard.com/daily-scoop",
                css_selector=".td-block-span12, .tdb-block-inner, .td_module_wrap, .td-block-span6, .td-excerpt",
                word_count_threshold=20,
                bypass_cache=True,
                wait_until="domcontentloaded",
                timeout=10000
            )
            await asyncio.sleep(1)
            soup = BeautifulSoup(result.html, 'html.parser')
            news_items = []

            for item in soup.select(".td-block-span12, .td_module_wrap, .td-block-span6"):
                title_elem = item.select_one("h3 a, .entry-title a, .td-post-title a")
                title = title_elem.get_text(strip=True) if title_elem else "Untitled Scoop Item"
                link = title_elem['href'] if title_elem and 'href' in title_elem.attrs else None
                if not link or not re.search(r'/(202[4-9])/', link):
                    continue
                content_elem = item.select_one("p, .td-excerpt, .td-post-text-excerpt")
                content = content_elem.get_text(strip=True) if content_elem else ""
                if len(content) < 50:
                    continue
                if query.lower() in title.lower() or query.lower() in content.lower():
                    news_items.append({
                        "title": title,
                        "content": content,
                        "source_url": link,
                        "source_site": "addisstandard",
                        "source_type": "crawl",
                        "published_date": "Not available",
                        "crawl_timestamp": datetime.now(timezone.utc).isoformat(),
                        "_id": str(uuid.uuid4())
                    })
            return news_items
        except Exception as e:
            logger.error(f"Failed to crawl daily-scoop: {e}")
            return []