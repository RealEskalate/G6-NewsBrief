package mongodb

import (
	"context"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type NewsRepositoryMongo struct {
	collection *mongo.Collection
}

func NewNewsRepositoryMongo(collection *mongo.Collection) contract.INewsRepository {
	return &NewsRepositoryMongo{
		collection: collection,
	}
}

// save news to mongodb
func (r *NewsRepositoryMongo) Save(news *entity.News) error {
	news.CreatedAt = time.Now()
	news.UpdatedAt = time.Now()
	_, err := r.collection.InsertOne(context.Background(), news)
	return err
}

func (r *NewsRepositoryMongo) Update(news *entity.News) error {
	news.UpdatedAt = time.Now()
	filter := bson.M{"_id": news.ID}
	update := bson.M{"$set": news}
	_, err := r.collection.UpdateOne(context.Background(), filter, update)
	return err
}

func (r *NewsRepositoryMongo) FindByID(id string) (*entity.News, error) {
	var news entity.News
	err := r.collection.FindOne(context.Background(), bson.M{"_id": id}).Decode(&news)
	if err != nil {
		return nil, err
	}
	return &news, nil
}

func (r *NewsRepositoryMongo) FindAll(page, limit int) ([]*entity.News, int64, int, error) {
	if page < 1 {
		page = 1 //default to first page
	}

	skip := int64((page - 1) * limit)
	opts := options.Find().SetLimit(int64(limit)).SetSkip(skip)
	cursor, err := r.collection.Find(context.Background(), bson.M{}, opts)
	if err != nil {
		return nil, 0, 0, err
	}

	defer cursor.Close(context.Background())
	var newsList []*entity.News
	for cursor.Next(context.Background()) {
		var news entity.News
		if err := cursor.Decode(&news); err != nil {
			return nil, 0, 0, err
		}
		newsList = append(newsList, &news)
	}

	total, err := r.collection.CountDocuments(context.Background(), bson.M{})
	if err != nil {
		return nil, 0, 0, err
	}
	totalPages := int(total) / limit
	if int(total)%limit != 0 {
		totalPages++
	}
	return newsList, total, totalPages, nil
}

// FindTrending returns news sorted by published_at desc, paginated
func (r *NewsRepositoryMongo) FindTrending(page, limit int) ([]*entity.News, int64, int, error) {
	if page < 1 {
		page = 1
	}
	if limit <= 0 {
		limit = 10
	}

	filter := bson.M{}
	skip := int64((page - 1) * limit)
	opts := options.Find().SetLimit(int64(limit)).SetSkip(skip).SetSort(bson.D{{Key: "published_at", Value: -1}})

	cursor, err := r.collection.Find(context.Background(), filter, opts)
	if err != nil {
		return nil, 0, 0, err
	}
	defer cursor.Close(context.Background())

	var newsList []*entity.News
	for cursor.Next(context.Background()) {
		var news entity.News
		if err := cursor.Decode(&news); err != nil {
			return nil, 0, 0, err
		}
		newsList = append(newsList, &news)
	}
	if err := cursor.Err(); err != nil {
		return nil, 0, 0, err
	}

	total, err := r.collection.CountDocuments(context.Background(), filter)
	if err != nil {
		return nil, 0, 0, err
	}
	totalPages := int(total) / limit
	if int(total)%limit != 0 {
		totalPages++
	}
	return newsList, total, totalPages, nil
}

// FindToday returns news from today's midnight to now, limited and sorted desc
func (r *NewsRepositoryMongo) FindToday(limit int) ([]*entity.News, int64, int, error) {
	if limit <= 0 {
		limit = 4
	}
	now := time.Now()
	year, month, day := now.Date()
	loc := now.Location()
	startOfDay := time.Date(year, month, day, 0, 0, 0, 0, loc)

	filter := bson.M{"published_at": bson.M{"$gte": startOfDay, "$lte": now}}
	opts := options.Find().SetLimit(int64(limit)).SetSort(bson.D{{Key: "published_at", Value: -1}})

	cursor, err := r.collection.Find(context.Background(), filter, opts)
	if err != nil {
		return nil, 0, 0, err
	}
	defer cursor.Close(context.Background())

	var newsList []*entity.News
	for cursor.Next(context.Background()) {
		var news entity.News
		if err := cursor.Decode(&news); err != nil {
			return nil, 0, 0, err
		}
		newsList = append(newsList, &news)
	}
	if err := cursor.Err(); err != nil {
		return nil, 0, 0, err
	}

	total, err := r.collection.CountDocuments(context.Background(), filter)
	if err != nil {
		return nil, 0, 0, err
	}
	// For today, totalPages not applicable for fixed top-N; return 1 when total>0 else 0
	totalPages := 1
	if total == 0 {
		totalPages = 0
	}
	return newsList, total, totalPages, nil
}

// FindBySourceIDs returns news where source_id is in the provided list, paginated
func (r *NewsRepositoryMongo) FindBySourceIDs(sourceIDs []string, page, limit int) ([]*entity.News, int64, int, error) {
	if page < 1 {
		page = 1
	}
	if limit <= 0 {
		limit = 10
	}

	filter := bson.M{"source_id": bson.M{"$in": sourceIDs}}
	skip := int64((page - 1) * limit)
	opts := options.Find().SetLimit(int64(limit)).SetSkip(skip).SetSort(bson.D{{Key: "published_at", Value: -1}})

	cursor, err := r.collection.Find(context.Background(), filter, opts)
	if err != nil {
		return nil, 0, 0, err
	}
	defer cursor.Close(context.Background())

	var newsList []*entity.News
	for cursor.Next(context.Background()) {
		var news entity.News
		if err := cursor.Decode(&news); err != nil {
			return nil, 0, 0, err
		}
		newsList = append(newsList, &news)
	}

	total, err := r.collection.CountDocuments(context.Background(), filter)
	if err != nil {
		return nil, 0, 0, err
	}
	totalPages := int(total) / limit
	if int(total)%limit != 0 {
		totalPages++
	}
	return newsList, total, totalPages, nil
}

// FindByIDs returns news by IDs (no pagination)
func (r *NewsRepositoryMongo) FindByIDs(ctx context.Context, ids []string) ([]*entity.News, error) {
	if len(ids) == 0 {
		return []*entity.News{}, nil
	}
	filter := bson.M{"_id": bson.M{"$in": ids}}
	opts := options.Find().SetSort(bson.D{{Key: "published_at", Value: -1}})
	cursor, err := r.collection.Find(ctx, filter, opts)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)
	var list []*entity.News
	for cursor.Next(ctx) {
		var news entity.News
		if err := cursor.Decode(&news); err != nil {
			return nil, err
		}
		list = append(list, &news)
	}
	return list, cursor.Err()
}

// FindByTopicID returns news where the topics array contains the given topic ID, paginated
func (r *NewsRepositoryMongo) FindByTopicID(ctx context.Context, topicID string, page, limit int) ([]*entity.News, int64, int, error) {
	if page < 1 {
		page = 1
	}
	if limit <= 0 {
		limit = 10
	}
	filter := bson.M{"topics": topicID}
	skip := int64((page - 1) * limit)
	opts := options.Find().SetLimit(int64(limit)).SetSkip(skip).SetSort(bson.D{{Key: "published_at", Value: -1}})

	cursor, err := r.collection.Find(ctx, filter, opts)
	if err != nil {
		return nil, 0, 0, err
	}
	defer cursor.Close(ctx)

	var newsList []*entity.News
	for cursor.Next(ctx) {
		var news entity.News
		if err := cursor.Decode(&news); err != nil {
			return nil, 0, 0, err
		}
		newsList = append(newsList, &news)
	}
	if err := cursor.Err(); err != nil {
		return nil, 0, 0, err
	}

	total, err := r.collection.CountDocuments(ctx, filter)
	if err != nil {
		return nil, 0, 0, err
	}
	totalPages := int(total) / limit
	if int(total)%limit != 0 {
		totalPages++
	}
	return newsList, total, totalPages, nil
}
