import chromadb
from sentence_transformers import SentenceTransformer
from typing import List, Dict
from app.models.news import NewsArticle
import logging

logger = logging.getLogger(__name__)

class VectorDBService:
    def __init__(self, client: chromadb.Client):
        self.client = client
        self.collection = self.client.get_or_create_collection(name="news_articles")
        self.model = SentenceTransformer('all-MiniLM-L6-v2')  # Lightweight, fast embeddings

    def generate_embedding(self, text: str) -> List[float]:
        """Generate embedding for a given text."""
        return self.model.encode(text, convert_to_tensor=False).tolist()

    def store_articles(self, articles: List[NewsArticle]):
        """Store news articles in ChromaDB with embeddings."""
        documents = []
        embeddings = []
        metadatas = []
        ids = []

        for i, article in enumerate(articles):
            text = f"{article.title} {article.body}"  # Combine title and body for embedding
            embedding = self.generate_embedding(text)
            documents.append(text)
            embeddings.append(embedding)
            metadatas.append({
                "title": article.title,
                "source_url": article.source_url,
                "source_type": article.source_type,
                "source_site": article.source_site or "unknown",
                "keyword": article.keyword or "",
                "date": article.date.isoformat() if article.date else "Not available"
            })
            ids.append(f"article_{i}_{article.source_url}")

        try:
            self.collection.upsert(
                documents=documents,
                embeddings=embeddings,
                metadatas=metadatas,
                ids=ids
            )
            
            logger.info(f"Stored {len(articles)} articles in ChromaDB")
        except Exception as e:
            logger.error(f"Failed to store articles: {e}")

    def search_articles(self, query: str, top_k: int = 5) -> List[Dict]:
        """Search articles by semantic similarity."""
        query_embedding = self.generate_embedding(query)
        try:
            results = self.collection.query(
                query_embeddings=[query_embedding],
                n_results=top_k
            )
            return [
                {
                    "title": meta["title"],
                    "source_url": meta["source_url"],
                    "source_type": meta["source_type"],
                    "source_site": meta["source_site"],
                    "keyword": meta["keyword"],
                    "date": meta["date"],
                    "text": doc
                } for doc, meta in zip(results["documents"][0], results["metadatas"][0])
            ]
        except Exception as e:
            logger.error(f"Search failed: {e}")
            return []