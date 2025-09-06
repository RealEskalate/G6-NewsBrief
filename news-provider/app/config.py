from typing import Dict, List

# ChromaDB configuration
CHROMA_DB_PATH = "/Users/m2air/Desktop/scraper-service/chroma_db"

# Define genres with associated keywords and category feeds
GENRES: Dict[str, Dict] = {
    "politics": {
        "keywords": ["politics", "government", "election", "policy", "parliament", "diplomacy", "ፖለቲካ", "መንግስት", "ምርጫ"],
        "category_feeds": {
            "Addis Standard": "https://addisstandard.com/category/politics/feed/",
            "Addis Standard Amharic": "https://addisstandard.com/Amharic/?cat=34&feed=rss2",  # Politics in Amharic
            "Fana Media Corporation": "https://www.fanamc.com/%e1%8b%9c%e1%8a%93/",  # Amharic news (general, filtered by keywords)
            "Ethiopian Reporter": "https://ethiopianreporter.com/politics/",  # Amharic politics
            "Amhara TV": "https://www.ameco.et/category/%e1%8b%9c%e1%8a%93/national/",  # National news (politics)
            "EBC": "https://www.ebc.et/Home/CategorialNews?CatId=1",  # Ethiopia news (politics)
        }
    },
    "sports": {
        "keywords": ["sports", "football", "athletics", "basketball", "olympics", "tournament", "ስፖርት", "እግር ኳስ"],
        "category_feeds": {
            "Fana Media Corporation": "https://www.fanamc.com/%e1%88%b5%e1%8d%93%e1%88%ad%e1%89%b5/",  # Amharic sports
            "Ethiopian Reporter": "https://ethiopianreporter.com/sport/",  # Amharic sports
            "Amhara TV": "https://www.ameco.et/sport/category/local-sport/",  # Local sports
            "EBC": "https://www.ebc.et/Home/CategorialNews?CatId=8",  # Sports in Amharic
        }
    },
    "business": {
        "keywords": ["business", "economy", "finance", "market", "trade", "investment", "ቢዝነስ", "ኢኮኖሚ"],
        "category_feeds": {
            "Addis Standard": "https://addisstandard.com/category/business/feed/",  # English business
            "Addis Standard Amharic": "https://addisstandard.com/Amharic/?cat=39&feed=rss2",  # Business in Amharic
            "Fana Media Corporation": "https://www.fanamc.com/%e1%89%a2%e1%8b%9d%e1%8a%90%e1%88%b5/",  # Amharic business
            "Ethiopian Reporter": "https://ethiopianreporter.com/business/",  # Amharic business
            "EBC": "https://www.ebc.et/Home/CategorialNews?CatId=3",  # Business in Amharic
        }
    },
    "others": {
        "keywords": ["culture", "lifestyle", "entertainment", "education", "health", "technology", "ህግ", "ፍትህ", "ባህል"],
        "category_feeds": {
            "Addis Standard": "https://addisstandard.com/category/law-order/feed/",  # English law and justice
            "Addis Standard Amharic": "https://addisstandard.com/Amharic/?cat=35&feed=rss2",  # Law and justice in Amharic
            "Fana Media Corporation": "https://www.fanamc.com/%e1%8b%9c%e1%8a%93/",  # Amharic news (general, filtered by keywords)
        }
    }
}

# Define news sources for Ethiopian news sites
NEWS_SOURCES: List[Dict] = [
    {
        "name": "Addis Standard",
        "feed": "https://addisstandard.com/feed/",
        "homepage": "https://addisstandard.com/",
        "category_feed": "https://addisstandard.com/category/news/feed/"
    },
    {
        "name": "Addis Standard Amharic",
        "feed": "https://addisstandard.com/Amharic/?feed=rss2",
        "homepage": "https://addisstandard.com/Amharic/",
        "category_feed": "https://addisstandard.com/Amharic/?cat=36&feed=rss2"  # Daily news
    },
    {
        "name": "Fana Media Corporation",
        "feed": None,  # No RSS feed available
        "homepage": "https://www.fanamc.com/",
        "category_feed": "https://www.fanamc.com/%e1%8b%9c%e1%8a%93/"  # Amharic news
    },
    {
        "name": "Ethiopian Reporter",
        "feed": None,  # No RSS feed available
        "homepage": "https://ethiopianreporter.com/",
        "category_feed": "https://ethiopianreporter.com/news/"  # Amharic news
    },
    {
        "name": "EBC",
        "feed": None,  # No RSS feed available
        "homepage": "https://www.ebc.et/",
        "category_feed": "https://www.ebc.et/Home/CategorialNews?CatId=1"  # Ethiopia news
    },
    {
        "name": "Amhara TV",
        "feed": None,  # No RSS feed available
        "homepage": "https://www.ameco.et/",
        "category_feed": "https://www.ameco.et/category/%e1%8b%9c%e1%8a%93/regional/"  # Amhara regional news
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
    "addis standard amharic": {
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
    "ebc": {
        "selectors": {
            "title": "h1.post-title, h1.entry-title, h1.article-title, h1, .title",
            "content": ".entry-content p, .post-content p, .article-content p, .content p, article p",
            "date": ".entry-date, .post-date, .published, .date-published, meta[property='article:published_time']",
            "links": ".entry-title a, .post-title a, .article-title a, h3 a, .news-item a"
        }
    },
    "amhara tv": {
        "selectors": {
            "title": "h1.post-title, h1.entry-title, h1.article-title, h1, .title",
            "content": ".entry-content p, .post-content p, .article-content p, .content p, article p",
            "date": ".entry-date, .post-date, .published, .date-published, meta[property='article:published_time']",
            "links": ".entry-title a, .post-title a, .article-title a, h3 a, .news-item a"
        }
    }
}