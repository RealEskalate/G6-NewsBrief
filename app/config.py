from os import getenv
from typing import Dict, List
# Load CHROMA_DB_PATH from .env
CHROMA_DB_PATH = getenv("CHROMA_DB_PATH", "./chroma_data")

# Define news sources for Ethiopian news sites
NEWS_SOURCES: List[Dict] = [
    {
        "name": "Addis Standard",
        "feed": "https://addisstandard.com/feed/",
        "homepage": "https://addisstandard.com/",
        "category_feed": "https://addisstandard.com/category/news/feed/"
    },
    {
        "name": "Fana Media Corporation",
        "feed": "https://www.fanamc.com/english/feed/",
        "homepage": "https://www.fanamc.com/",
        "category_feed": "https://www.fanamc.com/category/news/feed/"
    },
    {
        "name": "Ethiopian Reporter",
        "feed": "https://ethiopianreporter.com/feed/",
        "homepage": "https://ethiopianreporter.com/",
        "category_feed": "https://ethiopianreporter.com/category/news/feed/"
    },
    {
        "name": "Oromia Broadcasting Network",
        "feed": "https://obn.com.et/feed/",
        "homepage": "https://obn.com.et/",
        "category_feed": "https://obn.com.et/category/articles/feed/"
    },
    {
        "name": "EHPEA",
        "feed": "https://ehpea.org/feed/",
        "homepage": "https://ehpea.org/",
        "category_feed": "https://ehpea.org/category/news/feed/"
    }
]

# Site-specific configurations for selectors
SITE_CONFIGS: Dict[str, Dict] = {
    "addis standard": {
        "selectors": {
            "title": "h1.entry-title, h1.td-post-title, h1.post-title, h1, .tdb-title-text",
            "content": ".entry-content p, .td-post-content p, .post-content p, .content p, .td-post-content h2, .entry-content h2, .td-post-content h3, .entry-content h3, .tdb-block-inner p, .td-block-span12 p, .td-block-span6 p, .td-excerpt, article p",
            "date": ".entry-date, .td-post-date time, .post-date, .date-published, meta[property='article:published_time']",
            "links": ".entry-title a, .td-post-title a, .post-title a, h3 a, .td_module_wrap a, .tdb-block-inner a, .td-block-span12 a, .td-block-span6 a"
        }
    },
    "fana media corporation": {
        "selectors": {
            "title": "h1.post-title, h1.entry-title, h1, .entry-title",
            "content": ".entry-content p, .post-content p, .content p, article p",
            "date": ".post-date, .entry-date, meta[name='dc.date']",
            "links": ".entry-title a, .post-title a, h3 a"
        }
    },
    "ethiopian reporter": {
        "selectors": {
            "title": "h1.post-title, h1.entry-title, h1, .title",
            "content": ".entry-content p, .post-content p, .content p, article p",
            "date": ".entry-date, .post-date, .published",
            "links": ".entry-title a, .post-title a, h2 a, h3 a"
        }
    },
    "oromia broadcasting network": {
        "selectors": {
            "title": "h1.entry-title, h1.post-title, h1, .title",
            "content": ".entry-content p, .post-content p, .content p, article p",
            "date": ".entry-date, .post-date, .published-date",
            "links": ".entry-title a, .post-title a, h3 a, .article-title a"
        }
    },
    "ehpea": {
        "selectors": {
            "title": "h1.entry-title, h1.post-title, h1, .news-title",
            "content": ".entry-content p, .post-content p, .content p, article p",
            "date": ".entry-date, .post-date, .date-published",
            "links": ".entry-title a, .post-title a, h3 a, .news-item a"
        }
    }
}