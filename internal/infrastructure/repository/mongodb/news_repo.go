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

func (r *NewsRepositoryMongo) FindAll(page, limit int) ([]*entity.News, int64, int, error){
	if page < 1{
		page = 1 //default to first page
	}
    
	skip := int64((page-1) * limit)
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


