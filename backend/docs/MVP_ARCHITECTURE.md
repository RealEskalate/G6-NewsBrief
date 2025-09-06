# NewsBrief MVP Architecture (2-Service Model)

## Simplified Service Layout

```
┌──────────────────────────────────┐
│          Core API (Go Gin)         │
│ • Auth & User Management         │
│ • Story & Feed Management        │
│ • Summarization (Gemini API)     │
│ • Notification Logic             │
│ • Daily Brief Generation         │
│ • Internal Job Scheduling        │
└───────────────┬──────────────────┘
                │
                ▼
┌───────────────┴──────────────────┐
│         RabbitMQ                 │
│ (Message Broker)                 │
│ • Scrape Requests                │
│ • Scrape Results                 │
│ • Internal Tasks (Summaries etc) │
└───────────────┬──────────────────┘
                │
                ▼
┌───────────────┴──────────────────┐
│          Scraper (FastAPI)       │
│ • Content Extraction             │
│ • Vector Embedding Generation    │
└───────────────┬──────────────────┘
                │
                ▼
┌───────────────┴──────────────────┐
│         External Services        │
│ • MongoDB (Data Persistence)     │
│ • Pinecone (Vector DB)           │
└──────────────────────────────────┘
```

## MVP Feature Scope (Consolidated)

### ✅ **Core API Responsibilities**

1.  **User Management & Auth**

    - Registration, login, password management.
    - JWT token handling.
    - User preferences and subscriptions.

2.  **Content Management**

    - Receives scraped content from RabbitMQ.
    - Generates short & medium summaries using Gemini API.
    - Manages stories, topics, and sources.
    - Handles text and semantic search requests.

3.  **Feed & Briefs**

    - Generates personalized feeds.
    - Creates daily briefs (morning/evening) via scheduled internal jobs.

4.  **Notifications**
    - Sends notifications (e.g., "brief is ready") via internal background jobs.

### ✅ **Scraper Service Responsibilities**

1.  **Content Extraction**

    - Receives scrape requests from RabbitMQ.
    - Scrapes article content from URLs.

2.  **Vectorization**
    - Generates vector embeddings from the scraped text.
    - Pushes scraped content and embeddings back to the Core API via RabbitMQ.

### 🚫 **Deferred for Post-MVP**

- Advanced Chatbot
- Real-time Notifications (WebSockets)
- Premium Features & Billing

## MVP Simplifications

### 1. Consolidated Core API

The biggest simplification is that the **Core API is now a monolith** for all business logic. This reduces the number of services to deploy and manage.

- **Internal Background Jobs**: Instead of separate services, the Core API will use Go routines and a scheduler (or a library like `gocron`) to trigger background tasks like brief generation and notifications. These tasks will publish jobs to RabbitMQ to be processed by the Core API's own workers.

```go
// Core API Main: Start web server and background workers
func main() {
    // Initialize RabbitMQ, Database, etc.

    // Start RabbitMQ consumers for different tasks
    go consumeScrapeResults()
    go consumeSummarizationTasks()
    go consumeNotificationTasks()

    // Start a scheduler for periodic jobs
    s := gocron.NewScheduler(time.UTC)
    s.Every(1).Day().At("06:00").Do(createDailyBriefs, "morning")
    s.Every(1).Day().At("18:00").Do(createDailyBriefs, "evening")
    s.StartAsync()

    // Start the Gin web server
    router.Run(":8080")
}
```

### 2. Simplified Asynchronous Flow

The interaction between the two services is straightforward:

1.  **Core API** publishes a `scrape_request` message to RabbitMQ.
2.  **Scraper** consumes the message, scrapes the site, generates embeddings.
3.  **Scraper** publishes a `scrape_result` message back to RabbitMQ.
4.  **Core API** consumes the result, stores it, and triggers internal summarization/notification jobs.

### 3. Enhanced MongoDB Schema for MVP

The database schema will now also include collections for `daily_briefs` and `notifications`.

```javascript
// collections.js - Additions for new features

db.daily_briefs.insertOne({
  _id: ObjectId("..."),
  user_id: ObjectId("..."),
  type: "morning",
  date: "2025-08-26",
  headline_story_id: ObjectId("..."),
  story_ids: [ObjectId("..."), ObjectId("...")],
  generated_at: new Date(),
});

db.notifications.insertOne({
  _id: ObjectId("..."),
  user_id: ObjectId("..."),
  type: "daily_brief_ready",
  title: "Your Morning Brief is ready!",
  message: "Catch up on the latest news for August 26.",
  data: { brief_id: ObjectId("...") },
  is_read: false,
  created_at: new Date(),
});
```

## MVP Deployment (2 Services)

This simplified model is much easier to deploy on Render.

```yaml
# render.yaml
services:
  # The Core API Monolith
  - type: web
    name: core-api
    env: go
    buildCommand: go build -o main ./cmd/api
    startCommand: ./main
    envVars:
      - key: MONGODB_URI
        fromDatabase:
          name: newsbrief-db
          property: connectionString
      - key: RABBITMQ_URL
        fromService:
          type: pserv
          name: rabbitmq
          property: url
      - key: PINECONE_API_KEY
        sync: false # Add in Render dashboard
      - key: GEMINI_API_KEY
        sync: false # Add in Render dashboard

  # The Scraper Service
  - type: web
    name: scraper
    env: python
    buildCommand: pip install -r requirements.txt
    startCommand: uvicorn main:app --host 0.0.0.0 --port 8001
    envVars:
      - key: RABBITMQ_URL
        fromService:
          type: pserv
          name: rabbitmq
          property: url
      - key: PINECONE_API_KEY
        sync: false # Add in Render dashboard

databases:
  - name: newsbrief-db
    databaseName: newsbrief
    plan: free
# RabbitMQ from a third-party provider like CloudAMQP
# This is represented as a private service for environment variable sharing.
# You will need to create this service in the Render dashboard and paste in the URL.
# - type: pserv
#   name: rabbitmq
#   envVars:
#     - key: url
#       value: amqp://user:pass@host/vhost
```

This 2-service architecture is more cost-effective and simpler to manage for an MVP, while still keeping the Python-based scraping logic isolated. It provides a clear path to break out features into separate microservices again in the future if needed.
