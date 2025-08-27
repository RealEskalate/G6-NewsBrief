from crawl4ai import AsyncWebCrawler
from app.config import SITE_CONFIGS
from bs4 import BeautifulSoup
from datetime import datetime, timezone
import logging
import re
import uuid
from typing import Dict
import asyncio

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

async def extract_article_content(crawler: AsyncWebCrawler, url: str, title: str, source_site: str, semaphore, query: str) -> Dict:
    """Crawl a single article URL to extract full content, title, and metadata."""
    async with semaphore:
        try:
            result = await crawler.arun(
                url=url,
                css_selector=".entry-content, .td-post-content, .post-content, .content, .tdb-block-inner, .td-block-span12, .td-block-span6, .td-excerpt, article",
                word_count_threshold=20,
                bypass_cache=True,
                wait_until="domcontentloaded",
                timeout=10000
            )
            await asyncio.sleep(1)
            soup = BeautifulSoup(result.html, 'html.parser')

            # Use SITE_CONFIGS selectors
            config = next((cfg for site, cfg in SITE_CONFIGS.items() if site in source_site.lower()), {})
            selectors = config.get("selectors", {})

            # Extract title
            if not title or len(title) < 20:
                title_selector = selectors.get("title", "h1.entry-title, h1.td-post-title, h1.post-title, h1, .tdb-title-text")
                title_element = soup.select_one(title_selector)
                title = title_element.get_text(strip=True) if title_element else title or "Untitled Article"

            # Extract content
            content_selector = selectors.get("content", ".entry-content p, .td-post-content p, .post-content p, .content p, .td-post-content h2, .entry-content h2, .td-post-content h3, .entry-content h3, .tdb-block-inner p, .td-block-span12 p, .td-block-span6 p, .td-excerpt, article p")
            content_elements = soup.select(content_selector)
            content = " ".join(elem.get_text(strip=True) for elem in content_elements)

            # Clean content
            unwanted_phrases = [
                "Trending", "Show More", "Back to top button", "Editor’s Note",
                "Random Article", "Sidebar", "Donate Here", "Facebook", "Twitter",
                "Telegram", "TikTok", "Subscribe", "Follow Us", "Courtesy of",
                "BY JOANNE BRUNO", "BY ZELA GAYLE", "BY ASHENAFI ZEDEBUB"
            ]
            for phrase in unwanted_phrases:
                content = content.replace(phrase, "")
            content = re.sub(r'\s+', ' ', content).strip()
            content = re.sub(r'\[.*?\]\(.*?\)', '', content).strip()

            # Extract published date
            date_selector = selectors.get("date", ".entry-date, .td-post-date time, .post-date, .date-published")
            published_date = result.metadata.get('date', '')
            if not published_date:
                meta_date = soup.select_one('meta[property="article:published_time"], meta[name="dc.date"]')
                published_date = meta_date['content'] if meta_date and 'content' in meta_date.attrs else None
                if not published_date:
                    date_element = soup.select_one(date_selector)
                    published_date = date_element.get_text(strip=True) if date_element else "Not available"

            # Skip invalid articles
            if len(content) < 50 or any(keyword in content.lower() for keyword in ["soup", "recipe", "privacy policy", "rastafarian", "advertisement"]):
                logger.warning(f"Skipping article {url}: Content too short or non-news (length={len(content)})")
                return None
            if published_date != "Not available":
                try:
                    year = int(re.search(r'\d{4}', published_date).group(0))
                    if year < 2024:
                        logger.warning(f"Skipping article {url}: Published before 2024 ({published_date})")
                        return None
                except (ValueError, AttributeError):
                    logger.warning(f"Skipping article {url}: Invalid published date ({published_date})")
                    return None

            return {
                "title": title,
                "content": content,
                "source_url": url,
                "source_site": source_site,
                "source_type": "crawl",
                "published_date": published_date,
                "crawl_timestamp": datetime.now(timezone.utc).isoformat(),
                "_id": str(uuid.uuid4())
            }
        except Exception as e:
            logger.error(f"Failed to crawl article {url}: {e}")
            return None