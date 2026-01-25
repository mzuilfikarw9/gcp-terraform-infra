package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq" // Postgres driver
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/segmentio/kafka-go"
)

// --- CONFIGURATION ---
const (
	DB_HOST      = "10.231.0.3" // Your SIT Postgres Instance
	DB_PORT      = 5432
	DB_USER      = "postgres"
	DB_PASSWORD  = "5p&h19Z.HbXG6}T1" // We will inject this securely later
	DB_NAME      = "postgres"
	KAFKA_BROKER = "kafka.default.svc.cluster.local:9092"
)

// --- PROMETHEUS METRICS ---
var (
	httpRequestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "ticket_api_requests_total",
			Help: "Total number of HTTP requests to the ticket system",
		},
		[]string{"method", "status"},
	)
	orderProcessingDuration = prometheus.NewHistogram(
		prometheus.HistogramOpts{
			Name:    "ticket_order_processing_seconds",
			Help:    "Time taken to process a ticket order",
			Buckets: prometheus.DefBuckets,
		},
	)
)

func init() {
	// Register metrics so Prometheus can scrape them
	prometheus.MustRegister(httpRequestsTotal)
	prometheus.MustRegister(orderProcessingDuration)
}

// --- KAFKA PRODUCER ---
func produceOrder(orderID string, count int) error {
	writer := kafka.NewWriter(kafka.WriterConfig{
		Brokers:  []string{KAFKA_BROKER},
		Topic:    "orders",
		Balancer: &kafka.LeastBytes{},
	})
	defer writer.Close()

	msg := map[string]interface{}{
		"order_id":  orderID,
		"count":     count,
		"timestamp": time.Now(),
	}
	jsonMsg, _ := json.Marshal(msg)

	return writer.WriteMessages(context.Background(),
		kafka.Message{Value: jsonMsg},
	)
}

func main() {
	// 1. Test Database Connection
	psqlInfo := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
		DB_HOST, DB_PORT, DB_USER, os.Getenv("DB_PASSWORD"), DB_NAME)

	db, err := sql.Open("postgres", psqlInfo)
	if err != nil {
		log.Fatal("Could not connect to DB:", err)
	}
	defer db.Close()

	// 2. Setup Web Server (Gin)
	r := gin.New()

	// Middleware: Metrics & Logging
	r.Use(func(c *gin.Context) {
		start := time.Now()
		c.Next()
		duration := time.Since(start).Seconds()
		status := fmt.Sprintf("%d", c.Writer.Status())

		httpRequestsTotal.WithLabelValues(c.Request.Method, status).Inc()
		orderProcessingDuration.Observe(duration)
	})

	// 3. Define Routes
	r.POST("/api/buy", func(c *gin.Context) {
		var jsonBody struct {
			Count int `json:"ticket_count"`
		}
		if err := c.BindJSON(&jsonBody); err != nil {
			c.JSON(400, gin.H{"error": "Invalid input"})
			return
		}

		orderID := fmt.Sprintf("ord-%d", time.Now().UnixNano())

		// Send to Kafka (Event Driven!)
		err := produceOrder(orderID, jsonBody.Count)
		if err != nil {
			log.Printf("Kafka Error: %v", err)
			c.JSON(500, gin.H{"error": "Failed to queue order"})
			return
		}

		c.JSON(200, gin.H{"status": "queued", "order_id": orderID})
	})

	// Health Check for Kubernetes
	r.GET("/health", func(c *gin.Context) {
		err := db.Ping()
		if err != nil {
			c.JSON(500, gin.H{"status": "db_down", "error": err.Error()})
			return
		}
		c.JSON(200, gin.H{"status": "ok"})
	})

	// Prometheus Endpoint
	r.GET("/metrics", gin.WrapH(promhttp.Handler()))

	log.Println("Ticket API starting on :8080...")
	r.Run(":8080")
}
