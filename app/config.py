from os import getenv

# Load CHROMA_DB_PATH from .env
CHROMA_DB_PATH = getenv("CHROMA_DB_PATH", "./chroma_data")

# Site configurations for Crawl4AI
SITE_CONFIGS = {
    "addisstandard": {
        "url": "https://addisstandard.com",
        "feed": "https://addisstandard.com/feed/",
        "selectors": {
            "title": "h1.entry-title, h1.td-post-title, h1.post-title, h1, .tdb-title-text",
            "content": ".entry-content p, .td-post-content p, .post-content p, .content p, .td-post-content h2, .entry-content h2, .td-post-content h3, .entry-content h3, .tdb-block-inner p, .td-block-span12 p, .td-block-span6 p, .td-excerpt, article p",
            "date": ".entry-date, .td-post-date time, .post-date, .date-published",
            "author": "span.author"
        }
    },
    "fanatv": {
        "url": "https://www.fanabc.com",
        "feed": "https://www.fanabc.com/feed/",
        "selectors": {
            "title": "h1.post-title, h1.entry-title, h1.td-post-title, h1, .tdb-title-text",
            "content": ".post-content p, .td-post-content p, .entry-content p, .content p, .td-post-content h2, .entry-content h2, .td-post-content h3, .entry-content h3, .tdb-block-inner p, .td-block-span12 p, .td-block-span6 p, .td-excerpt, article p",
            "date": ".post-date, .entry-date, .td-post-date time, .date-published",
            "author": "span.post-author"
        }
    }
}

NEWS_SOURCES = [
    {"name": "addisstandard", "feed": "https://addisstandard.com/feed/", "homepage": "https://addisstandard.com/"},
    {"name": "fanatv", "feed": "https://www.fanabc.com/feed/", "homepage": "https://www.fanabc.com/"},
    {"name": "Ethiopian Reporter", "feed": "https://ethiopianreporter.com/feed/", "homepage": "https://ethiopianreporter.com/"},
    {"name": "Oromia Broadcasting Network", "feed": "https://obn.com.et/feed/", "homepage": "https://obn.com.et/"},
    {"name": "EHPEA", "feed": "https://ehpea.org/feed/", "homepage": "https://ehpea.org/"}
]