# Postman: News Brief Core API

Quick steps to import and test endpoints.

## Import
- Import `news-brief-core-api.postman_collection.json`.
- Import environment `news-brief-local.postman_environment.json` and select it.

## Configure
- Ensure the API is running locally and listens on `http://localhost:8080`.
- If different, update the `base_url` variable in the environment.

## Run flow
1) Auth → Register (or use an existing user), then Auth → Login.
   - Tokens will be captured into the environment automatically.
2) Utilities → Ingest News (summarize then save) to simulate the scraper pipeline.
   - The created `news_id` is captured automatically.
3) Utilities → Summarize by news_id (optional re-run summarization).
4) Translation → Translate Text or Translate News Summary.
5) Chat → General Chat and Chat for News (uses `X-Session-ID`).

Protected routes in User and Admin folders use the `access_token` variable.
