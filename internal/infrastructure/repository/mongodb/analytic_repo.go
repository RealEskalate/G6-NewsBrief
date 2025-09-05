package mongodb

import (
	"context"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type AnalyticRepository struct {
	collection *mongo.Collection
}

func NewAnalyticRepository(colln *mongo.Collection) contract.IAnalyticRepository {
	return &AnalyticRepository{
		collection: colln,
	}
}

func (r *AnalyticRepository) InitializeAnalytics(ctx context.Context) error {
	filter := bson.M{"_id": "singleton"}
	update := bson.M{"$setOnInsert": entity.Analytic{
		ID:           "singleton",
		TotalUsers:   0,
		TotalSources: 0,
		TotalNews:    0,
		TotalTopics:  0,
	}}
	opt := options.Update().SetUpsert(true)
	_, err := r.collection.UpdateOne(ctx, filter, update, opt)
	return err
}

func (r *AnalyticRepository) IncrementTotalUser(ctx context.Context) error {
	_, err := r.collection.UpdateOne(ctx, bson.M{"_id": "singleton"}, bson.M{"$inc": bson.M{"total_users": 1}})
	return err
}

func (r *AnalyticRepository) IncrementTotalSource(ctx context.Context) error {
	_, err := r.collection.UpdateOne(ctx, bson.M{"_id": "singleton"}, bson.M{"$inc": bson.M{"total_sources": 1}})
	return err
}

func (r *AnalyticRepository) IncrementTotalNews(ctx context.Context) error {
	_, err := r.collection.UpdateOne(ctx, bson.M{"_id": "singleton"}, bson.M{"$inc": bson.M{"total_news": 1}})
	return err
}

func (r *AnalyticRepository) IncrementTotalTopic(ctx context.Context) error {
	_, err := r.collection.UpdateOne(ctx, bson.M{"_id": "singleton"}, bson.M{"$inc": bson.M{"total_topics": 1}})
	return err
}

func (r *AnalyticRepository) GetAnalytics(ctx context.Context) (entity.Analytic, error) {
	var analytics entity.Analytic
	err := r.collection.FindOne(ctx, bson.M{"_id": "singleton"}).Decode(&analytics)
	return analytics, err
}
