from fastapi import Depends
from sqlalchemy.orm import Session
from app.database import SessionLocal
import chromadb
from app.config import CHROMA_DB_PATH

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_vector_db():
    client = chromadb.PersistentClient(path=CHROMA_DB_PATH)
    yield client