import asyncio
from crawl4ai import AsyncWebCrawler
from app.config import SITE_CONFIGS
import logging
from typing import List, Dict
from datetime import datetime, timezone
import uuid

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

async def crawl_homepages(crawler: AsyncWebCrawler, sources: List[Dict], urls: List[str], query: str, semaphore) -> List[Dict]:
    """Crawl homepages for article links, deferring date filtering to article extraction."""
    scrape_articles = []
    for source in sources:
        if source['homepage'] not in urls:
            continue
        logger.info(f"Scraping homepage: {source['homepage']}")
        for attempt in range(2):
            try:
                config = SITE_CONFIGS.get(source['name'].lower(), {})
                link_selector = config.get("selectors", {}).get("links", ".entry-title a, .td-post-title a, .post-title a, h3 a, .td_module_wrap a, .tdb-block-inner a, .td-block-span12 a, .td-block-span6 a")
                async with semaphore:
                    result = await crawler.arun(
                        url=source['homepage'],
                        css_selector=link_selector,
                        extract_links=True,
                        word_count_threshold=10,
                        bypass_cache=True,
                        wait_until="domcontentloaded",
                        timeout=20000
                    )
                    raw_links = result.links.get('internal', [])
                    for link in raw_links[:50]:
                        href = link['href']
                        title = link['text'].strip()
                        if ('category' in href.lower() or
                            'tag' in href.lower() or
                            href.endswith('/') or
                            any(keyword in href.lower() for keyword in [
                                'about-us', 'wp-login', 'contact-us',
                                'journal.addisstandard', 'peptide', 'roasted-garlic',
                                'exodus', 'women-at-the-top', 'advertisement'
                            ]) or
                            any(keyword in title.lower() for keyword in ["soup", "recipe", "privacy", "rastafarian"])):
                            logger.debug(f"Excluding scrape URL {href}: Matches exclusion criteria")
                            continue
                        if ('/202[4-9]/' in href or
                            'news' in href.lower() or
                            'analysis' in href.lower() or
                            'editorial' in href.lower() or
                            'opinion' in href.lower() or
                            'exclusive' in href.lower()):
                            if not query or query.lower() in title.lower():
                                scrape_articles.append({
                                    "title": title or "Untitled Article",
                                    "source_url": href,
                                    "source_site": source['name'],
                                    "source_type": "crawl",
                                    "content": "",
                                    "published_date": "Not available",
                                    "crawl_timestamp": datetime.now(timezone.utc).isoformat(),
                                    "_id": str(uuid.uuid4())
                                })
                    break
            except Exception as e:
                logger.error(f"Attempt {attempt + 1} failed to scrape homepage {source['homepage']}: {e}")
                if attempt < 1:
                    await asyncio.sleep(5)
                    continue
    logger.info(f"Extracted {len(scrape_articles)} articles from homepages")
    return scrape_articles