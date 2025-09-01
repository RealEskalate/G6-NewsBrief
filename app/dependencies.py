from os import getenv
import chromadb
from app.config import CHROMA_DB_PATH

def get_vector_db():
    # client = chromadb.PersistentClient(path=CHROMA_DB_PATH)
    client = chromadb.CloudClient(
            api_key=getenv("CHROMA_DB_API_KEY"),
            tenant=getenv("CHROMA_DB_TENANT"),
            database=getenv("CHROMA_DB")
        )
    yield client