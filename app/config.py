import os
from dotenv import load_dotenv

load_dotenv()

# API keys
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
NEWSAPI_KEY = os.getenv("NEWSAPI_KEY")
TELEGRAM_API_ID = os.getenv("TELEGRAM_API_ID")
TELEGRAM_API_HASH = os.getenv("TELEGRAM_API_HASH")
CHROMA_DB_PATH = os.getenv("CHROMA_DB_PATH", "./chroma_data")

# News site configurations for Crawl4AI
SITE_CONFIGS = {
    "addisstandard": {
        "base_url": "https://addisstandard.com/",
        "search_url_template": "https://addisstandard.com/?s={keyword}",
        "article_list_selector": ".td-post-title a, .entry-title a, .td_module_wrap h3 a, .td-module-title a",
        "content_selector": ".td-post-content p, .entry-content p, .td-post-content h2, .entry-content h2, .td-post-content h3, .entry-content h3",
        "title_selector": "h1.entry-title, h1.td-post-title, h1",
        "date_selector": ".entry-date, .td-post-date time, .td-post-date",
        "date_meta_selector": 'meta[property="article:published_time"]',
        "date_patterns": [
            r'(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday),\s*(January|February|March|April|May|June|July|August|September|October|November|December)\s*\d{1,2}\s*\d{4}',
            r'\d{1,2}\s*(January|February|March|April|May|June|July|August|September|October|November|December)\s*\d{4}',
            r'(January|February|March|April|May|June|July|August|September|October|November|December)\s*\d{1,2},\s*\d{4}',
            r'\d{4}/\d{2}/\d{2}',
            r'\d{4}-\d{2}-\d{2}'
        ],
        "exclude_keywords": ["soup", "recipe", "privacy policy", "rastafarian", "about-us", "afaanoromoo", "amharic", "?random-post", "wp-login", "contact-us", "journal.addisstandard", "peptide", "roasted-garlic", "exodus", "women-at-the-top", "about", "contact"],
        "unwanted_phrases": ["Trending", "Show More", "Back to top button", "Editor’s Note", "Random Article", "Sidebar", "Donate Here", "Facebook", "Twitter", "Telegram", "TikTok", "Addis Standard", "Subscribe", "Follow Us", "Courtesy of", "BY JOANNE BRUNO", "BY ZELA GAYLE", "BY ASHENAFI ZEDEBUB"]
    },
    "fanatv": {
        "base_url": "https://www.fanabc.com/",
        "search_url_template": "https://www.fanabc.com/?s={keyword}",
        "article_list_selector": ".post-title a, .entry-title a, .post h3 a, .news-item a",
        "content_selector": ".post-content p, .entry-content p, .post-content h2, .entry-content h2, .post-content h3, .entry-content h3",
        "title_selector": "h1.post-title, h1.entry-title, h1",
        "date_selector": ".post-date, .entry-date, time",
        "date_meta_selector": 'meta[property="article:published_time"]',
        "date_patterns": [
            r'\d{1,2}/\d{1,2}/\d{4}',
            r'(January|February|March|April|May|June|July|August|September|October|November|December)\s*\d{1,2},\s*\d{4}',
            r'\d{4}-\d{2}-\d{2}',
            r'\d{2}-\d{2}-\d{4}'
        ],
        "exclude_keywords": ["recipe", "privacy policy", "contact", "about", "advertise", "category", "tag", "ስለ", "ያግኙን"],
        "unwanted_phrases": ["Fana Broadcasting", "Follow Us", "Subscribe", "Advertisement", "Social Media"]
    }
}