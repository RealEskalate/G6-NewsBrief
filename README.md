# 📰 AI News Brief Application

A **FastAPI-based application** for gathering, cleaning, and storing news from **web crawling (Crawl4AI)**, **NewsAPI**, and **Telegram channels**, with **semantic search using ChromaDB**.

## ⚙️ Setup

### 1. Clone the repository
```bash
git clone <repo_url>
cd news-crawler
````

### 2. Create and activate a virtual environment

```bash
python3 -m venv myenv
source myenv/bin/activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Set up Crawl4AI

```bash
crawl4ai-setup
crawl4ai-doctor
python -m playwright install --with-deps chromium
```

### 5. Set up spaCy

```bash
python -m spacy download en_core_web_sm
```

### 6. Configure environment variables

Create a `.env` file:

```bash
echo "OPENAI_API_KEY=your_openai_key" >> .env
echo "NEWSAPI_KEY=your_newsapi_key" >> .env
echo "TELEGRAM_API_ID=your_telegram_api_id" >> .env
echo "TELEGRAM_API_HASH=your_telegram_api_hash" >> .env
echo "DATABASE_URL=sqlite:///./news.db" >> .env
echo "CHROMA_DB_PATH=./chroma_data" >> .env
```

### 7. Run the app

```bash
uvicorn app.main:app --reload
```

➡️ Access Swagger UI at: [http://localhost:8000/docs](http://localhost:8000/docs)

## 📡 API Endpoints

* **POST** `/api/v1/news/gather` → Gather raw news from **Crawl4AI**, **NewsAPI**, or **Telegram** and store in **ChromaDB**.
* **POST** `/api/v1/news/clean` → Clean raw data into structured articles and store in **ChromaDB**.
* **POST** `/api/v1/news/search` → Perform semantic search on stored articles.
* **GET** `/api/v1/news/briefs?query=topic&top_k=5` → Generate AI-powered news brief using vector search.

## 📝 Notes

* Crawl4AI is configured for **Addis Standard** and **Fana TV**; add more sites in `app/config.py`.
* **ChromaDB** stores embeddings in `CHROMA_DB_PATH` for persistent storage.
* Respect **robots.txt** and **rate limits** for ethical crawling.
* Telegram requires **public channel handles** (e.g., `@bbcnews`).
