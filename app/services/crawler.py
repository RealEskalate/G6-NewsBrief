import asyncio
import logging
from crawl4ai import AsyncWebCrawler
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse
from app.config import SITE_CONFIGS
from app.utils.helpers import parse_date, is_within_date_range, matches_keyword, clean_content

logger = logging.getLogger(__name__)

async def extract_article_content(crawler, url, title, config, keyword=None):
    """Crawl a single article URL and extract its content, title, and metadata."""
    try:
        result = await crawler.arun(
            url=url,
            css_selector=config["content_selector"],
            word_count_threshold=50,
            bypass_cache=True,
            wait_until="domcontentloaded",
            timeout=120000
        )
        
        soup = BeautifulSoup(result.html, 'html.parser')
        
        # Extract title
        if not title or len(title) < 15:
            title_element = soup.select_one(config["title_selector"])
            title = title_element.get_text(strip=True) if title_element else title or "Untitled Article"
        
        # Extract content
        content_elements = soup.select(config["content_selector"])
        content = " ".join(elem.get_text(strip=True) for elem in content_elements)
        
        # Clean content
        content = clean_content(content, config["unwanted_phrases"], config["exclude_keywords"])
        if not content:
            logger.warning(f"Skipping {url}: Content too short or contains excluded keywords")
            return None
        
        # Keyword check
        if not matches_keyword(title, content, keyword):
            logger.info(f"Skipping {url}: Does not match keyword '{keyword}'")
            return None
        
        # Extract published date
        published_date = result.metadata.get('date', '')
        if not published_date:
            meta_date = soup.select_one(config["date_meta_selector"])
            published_date = meta_date['content'] if meta_date and 'content' in meta_date.attrs else None
            if not published_date:
                date_element = soup.select_one(config["date_selector"])
                published_date = date_element.get_text(strip=True) if date_element else None
                if not published_date:
                    for pattern in config["date_patterns"]:
                        date_match = re.search(pattern, content)
                        if date_match:
                            published_date = date_match.group(0)
                            break
                    if not published_date:
                        title_date = re.search(r'(January|February|March|April|May|June|July|August|September|October|November|December)\s*\d{1,2},\s*\d{4}', title)
                        published_date = title_date.group(0) if title_date else "Not available"
        
        # Date filter
        if not await is_within_date_range(published_date):
            logger.info(f"Skipping {url}: Published date {published_date} is older than 7 days")
            return None
        
        return {
            "title": title,
            "content": content,
            "published_date": published_date
        }
    except Exception as e:
        logger.error(f"Failed to crawl {url}: {e}")
        return None

async def crawl_news(urls, query=None):
    """Crawl news sites for recent articles (general or keyword-based)."""
    async with AsyncWebCrawler(verbose=True, playwright_stealth=True) as crawler:
        all_news_data = []
        for url in urls:
            # Find matching site config
            site_name = None
            config = None
            for name, cfg in SITE_CONFIGS.items():
                if urlparse(url).netloc == urlparse(cfg["base_url"]).netloc:
                    site_name = name
                    config = cfg
                    break
            if not config:
                logger.warning(f"No config found for {url}")
                continue
            
            # Determine crawl URL
            crawl_url = config["search_url_template"].format(keyword=query) if query and "search_url_template" in config else url
            mode = "keyword" if query else "general"
            logger.info(f"Crawling {site_name} in {mode} mode {'for ' + query if query else ''} at {crawl_url}")
            
            # Crawl homepage or search page
            try:
                homepage_result = await crawler.arun(
                    url=crawl_url,
                    css_selector=config["article_list_selector"],
                    extract_links=True,
                    word_count_threshold=10,
                    bypass_cache=True,
                    wait_until="domcontentloaded",
                    timeout=120000
                )
                
                if not homepage_result.links.get('internal'):
                    logger.warning(f"No internal links found for {site_name}. Check selector.")
                    continue
            except Exception as e:
                logger.error(f"Failed to crawl {site_name}: {e}")
                continue
            
            # Normalize and filter links
            raw_links = homepage_result.links.get('internal', [])
            articles = []
            base_domain = urlparse(config["base_url"]).netloc
            for link in raw_links:
                href = link['href']
                title = link['text'].strip()
                href = urljoin(config["base_url"], href)
                if urlparse(href).netloc != base_domain:
                    continue
                if (not any(kw in href.lower() for kw in config["exclude_keywords"]) and
                    not href.endswith('/') and
                    not any(kw in title.lower() for kw in config["exclude_keywords"])):
                    if not query or matches_keyword(title, "", query):
                        articles.append({
                            "title": title or "Untitled Article",
                            "link": href
                        })
                if len(articles) >= 10:
                    break
            
            if not articles:
                logger.warning(f"No matching articles for {site_name} in {mode} mode.")
                continue
            
            logger.info(f"Found {len(articles)} articles from {site_name}: {[a['title'] for a in articles]}")
            
            # Crawl article details
            for article in articles:
                article_data = await extract_article_content(crawler, article["link"], article["title"], config, query)
                if article_data:
                    news_item = {
                        "title": article_data["title"],
                        "content": article_data["content"],
                        "source_url": article["link"],
                        "source_type": "crawl",
                        "source_site": site_name,
                        "crawl_timestamp": datetime.now(timezone.utc).isoformat(),
                        "published_date": article_data["published_date"],
                        "keyword": query
                    }
                    all_news_data.append(news_item)
                await asyncio.sleep(2)
        
        return all_news_data