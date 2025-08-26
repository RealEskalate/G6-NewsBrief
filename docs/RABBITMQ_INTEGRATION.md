# RabbitMQ Integration Guide

This document outlines how to integrate and use RabbitMQ for asynchronous task processing in the NewsBrief application.

## 1. Architecture Overview

RabbitMQ serves as a message broker that decouples the Core API from the Scraper and Summarizer services. This makes the system more resilient and scalable by handling long-running tasks asynchronously.

- **Core API**: Publishes messages to a queue when a new task (e.g., scraping a new URL) is required.
- **Scraper Service**: Consumes messages from a `scrape_tasks` queue, performs the scraping, and then publishes a message to a `summarize_tasks` queue upon completion.
- **Summarizer Service**: Consumes messages from the `summarize_tasks` queue to generate and store article summaries.

## 2. RabbitMQ Setup (with Docker)

The `docker-compose.yml` file in the root of the project includes the RabbitMQ service. To start it, run:

```bash
docker-compose up -d rabbitmq
```

This will start a RabbitMQ container with the management plugin enabled. You can access the management UI at `http://localhost:15672` (default credentials: `guest`/`guest`).

## 3. Queue and Message Structure

### 3.1. Scraping Queue

- **Queue Name**: `scrape_tasks`
- **Description**: Used to request the scraping of a new article URL.
- **Publisher**: Core API
- **Consumer**: Scraper Service

**Sample Message Body:**

```json
{
  "url": "https://www.example.com/news/article-123",
  "source_key": "example_news"
}
```

### 3.2. Summarization Queue

- **Queue Name**: `summarize_tasks`
- **Description**: Used to request the summarization of scraped text.
- **Publisher**: Scraper Service
- **Consumer**: Summarizer Service

**Sample Message Body:**

```json
{
  "story_id": "63f8c7b5b9a0b3e6f8e9e3e5",
  "text": "This is the full text of the scraped article...",
  "title": "Example Article Title",
  "target_lang": "en"
}
```

## 4. Implementation Examples

### 4.1. Publishing a Message (Go - Core API)

Here is an example of how the Core API can publish a message to the `scrape_tasks` queue.

**Dependencies:**

```bash
go get github.com/streadway/amqp
```

**Code:**

```go
package main

import (
	"encoding/json"
	"log"

	"github.com/streadway/amqp"
)

func failOnError(err error, msg string) {
	if err != nil {
		log.Fatalf("%s: %s", msg, err)
	}
}

type ScrapeTask struct {
	URL       string `json:"url"`
	SourceKey string `json:"source_key"`
}

func main() {
	// Connect to RabbitMQ
	conn, err := amqp.Dial("amqp://guest:guest@localhost:5672/")
	failOnError(err, "Failed to connect to RabbitMQ")
	defer conn.Close()

	ch, err := conn.Channel()
	failOnError(err, "Failed to open a channel")
	defer ch.Close()

	// Declare the queue
	q, err := ch.QueueDeclare(
		"scrape_tasks", // name
		true,           // durable
		false,          // delete when unused
		false,          // exclusive
		false,          // no-wait
		nil,            // arguments
	)
	failOnError(err, "Failed to declare a queue")

	// Create the message
	task := ScrapeTask{
		URL:       "https://www.example.com/news/article-123",
		SourceKey: "example_news",
	}
	body, err := json.Marshal(task)
	failOnError(err, "Failed to marshal JSON")

	// Publish the message
	err = ch.Publish(
		"",     // exchange
		q.Name, // routing key
		false,  // mandatory
		false,  // immediate
		amqp.Publishing{
			ContentType: "application/json",
			Body:        body,
		})
	failOnError(err, "Failed to publish a message")
	log.Printf(" [x] Sent %s", body)
}
```

### 4.2. Consuming a Message (Python - Scraper Service)

Here is an example of how the Scraper service can consume messages from the `scrape_tasks` queue.

**Dependencies:**

```bash
pip install pika
```

**Code:**

```python
import pika
import json
import time

def main():
    connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
    channel = connection.channel()

    channel.queue_declare(queue='scrape_tasks', durable=True)
    print(' [*] Waiting for messages. To exit press CTRL+C')

    def callback(ch, method, properties, body):
        task = json.loads(body)
        print(f" [x] Received {task}")

        # Simulate scraping work
        time.sleep(2)

        print(f" [x] Done scraping {task['url']}")

        # Acknowledge the message
        ch.basic_ack(delivery_tag=method.delivery_tag)

    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(queue='scrape_tasks', on_message_callback=callback)

    channel.start_consuming()

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print('Interrupted')
        sys.exit(0)
```

## 5. Error Handling and Retries

For robustness, consider implementing a dead-letter queue (DLQ) to handle messages that cannot be processed successfully. This allows you to inspect and manually retry or discard failed tasks without losing them.

When declaring a queue, you can specify `x-dead-letter-exchange` and `x-dead-letter-routing-key` arguments to redirect failed messages.

## 6. Monitoring

The RabbitMQ Management UI (`http://localhost:15672`) provides a detailed overview of queues, connections, channels, and message rates, which is invaluable for monitoring the health of your asynchronous architecture.
