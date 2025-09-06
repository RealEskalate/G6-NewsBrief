from app.services.lang_detector import detect_language
import chromadb
from typing import List, Dict
import logging

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

class VectorDBService:
    def __init__(self, client: chromadb.Client):
        self.client = client
        self.collection = client.get_or_create_collection("news_articles")

    def get_articles(self, limit: int = 10) -> List[Dict]:
        """Retrieve articles from ChromaDB."""
        try:
            results = self.collection.get(limit=limit)
            articles = []
            for i in range(len(results["ids"])):
                articles.append({
                    "id": results["ids"][i],
                    "title": results["metadatas"][i]["title"],
                    "text": results["documents"][i],
                    "source_url": results["metadatas"][i]["source_url"],
                    "source_site": results["metadatas"][i]["source_site"],
                    "source_type": results["metadatas"][i]["source_type"],
                    "published_date": results["metadatas"][i]["published_date"],
                    "crawl_timestamp": results["metadatas"][i]["crawl_timestamp"],
                    "lang": results["metadatas"][i].get("lang", detect_language(results["documents"][i]))
                })
            logger.info(f"Retrieved {len(articles)} articles from ChromaDB")
            return articles
        except Exception as e:
            logger.error(f"Failed to retrieve articles: {e}")
            return []
        
    def add_article(self, article: Dict):
        """Add a single article to ChromaDB."""
        try:
            text = f"{article['title']} {article['content']}"
            self.collection.add(
                ids=[article['_id']],
                documents=[text],
                metadatas=[{
                    "title": article["title"],
                    "source_url": article["source_url"],
                    "source_site": article["source_site"],
                    "source_type": article["source_type"],
                    "published_date": article["published_date"],
                    "crawl_timestamp": article["crawl_timestamp"],
                    "lang": article.get("lang", detect_language(text))
                }]
            ) 
            logger.info(f"Stored article in ChromaDB: {article['title']} (ID: {article['_id']})")
        except Exception as e:
            logger.error(f"Failed to add article {article['title']}: {e}")

    def search_articles(self, query: str, top_k: int) -> List[Dict]:
        """Search articles semantically using ChromaDB."""
        try:
            results = self.collection.query(
                query_texts=[query],
                n_results=top_k
            )
            articles = []
            for i in range(len(results["ids"][0])):
                articles.append({
                    "id": results["ids"][0][i],
                    "title": results["metadatas"][0][i]["title"],
                    "text": results["documents"][0][i],
                    "source_url": results["metadatas"][0][i]["source_url"],
                    "source_site": results["metadatas"][0][i]["source_site"],
                    "source_type": results["metadatas"][0][i]["source_type"],
                    "published_date": results["metadatas"][0][i]["published_date"],
                    "crawl_timestamp": results["metadatas"][0][i]["crawl_timestamp"],
                    "distance": results["distances"][0][i],
                    "lang": results["metadatas"][0][i].get("lang", detect_language(results["documents"][0][i]))
                })
            logger.info(f"Retrieved {len(articles)} articles for query: {query}")
            return articles
        except Exception as e:
            logger.error(f"Failed to search articles: {e}")
            return []

    def store_articles(self, articles: List[Dict]):
        """Store multiple articles in ChromaDB."""
        for article in articles:
            self.add_article(article)