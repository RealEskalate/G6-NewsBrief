import chromadb
from app.config import CHROMA_DB_PATH

def get_vector_db():
    client = chromadb.PersistentClient(path=CHROMA_DB_PATH)
    yield client