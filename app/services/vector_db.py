from sentence_transformers import SentenceTransformer
import chromadb
from typing import List, Dict

class VectorDBService:
    def __init__(self, client: chromadb.Client):
        self.client = client
        self.collection = client.get_or_create_collection("news_articles")
        self.model = SentenceTransformer("all-MiniLM-L6-v2")

    def generate_embedding(self, text: str) -> List[float]:
        """Generate embedding for the given text."""
        try:
            embedding = self.model.encode(text, convert_to_tensor=False).tolist()
            return embedding
        except Exception as e:
            print(f"Failed to generate embedding for text: {e}")
            return []

    def add_article(self, article: Dict):
        """Add a single article to ChromaDB."""
        try:
            text = f"{article['title']} {article['content']}"
            embedding = self.generate_embedding(text)
            if not embedding:
                print(f"Skipping article {article['title']}: Empty embedding")
                return
            self.collection.add(
                ids=[article['_id']],
                embeddings=[embedding],
                documents=[text],
                metadatas=[{
                    "title": article["title"],
                    "source_url": article["source_url"],
                    "source_site": article["source_site"],
                    "source_type": article["source_type"],
                    "published_date": article["published_date"],
                    "crawl_timestamp": article["crawl_timestamp"]
                }]
            )
        except Exception as e:
            print(f"Failed to add article {article['title']}: {e}")

    def search_articles(self, query: str, top_k: int) -> List[Dict]:
        """Search articles semantically using ChromaDB."""
        try:
            query_embedding = self.generate_embedding(query)
            if not query_embedding:
                print(f"Failed to generate query embedding for: {query}")
                return []
            results = self.collection.query(
                query_embeddings=[query_embedding],
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
                    "distance": results["distances"][0][i]
                })
            return articles
        except Exception as e:
            print(f"Failed to search articles: {e}")
            return []