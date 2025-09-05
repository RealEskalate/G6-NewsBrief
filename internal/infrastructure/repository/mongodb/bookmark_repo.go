package mongodb

import (
	"context"
	"errors"
	"time"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type BookmarkRepository struct {
	col *mongo.Collection
}

func NewBookmarkRepository(db *mongo.Database) contract.IBookmarkRepository {
	r := &BookmarkRepository{col: db.Collection("bookmarks")}
	// unique index on (user_id, news_id)
	_, _ = r.col.Indexes().CreateOne(context.Background(), mongo.IndexModel{
		Keys:    bson.D{{Key: "user_id", Value: 1}, {Key: "news_id", Value: 1}},
		Options: options.Index().SetUnique(true),
	})
	return r
}

func (r *BookmarkRepository) Save(ctx context.Context, b entity.Bookmark) error {
	if b.CreatedAt.IsZero() {
		b.CreatedAt = time.Now().UTC()
	}
	_, err := r.col.InsertOne(ctx, b)
	if err != nil {
		// translate duplicate key errors to a domain-level error
		var we mongo.WriteException
		if errors.As(err, &we) {
			for _, e := range we.WriteErrors {
				if e.Code == 11000 {
					return contract.ErrAlreadyBookmarked
				}
			}
		}
		var bwe mongo.BulkWriteException
		if errors.As(err, &bwe) {
			for _, e := range bwe.WriteErrors {
				if e.Code == 11000 {
					return contract.ErrAlreadyBookmarked
				}
			}
		}
		return err
	}
	return nil
}

func (r *BookmarkRepository) Delete(ctx context.Context, userID, newsID string) error {
	_, err := r.col.DeleteOne(ctx, bson.M{"user_id": userID, "news_id": newsID})
	return err
}

func (r *BookmarkRepository) Exists(ctx context.Context, userID, newsID string) (bool, error) {
	err := r.col.FindOne(ctx, bson.M{"user_id": userID, "news_id": newsID}).Err()
	if err == mongo.ErrNoDocuments {
		return false, nil
	}
	return err == nil, err
}

func (r *BookmarkRepository) GetBookmarkedFlags(ctx context.Context, userID string, newsIDs []string) (map[string]bool, error) {
	cur, err := r.col.Find(ctx, bson.M{"user_id": userID, "news_id": bson.M{"$in": newsIDs}}, options.Find().SetProjection(bson.M{"news_id": 1}))
	if err != nil {
		return nil, err
	}
	defer cur.Close(ctx)
	flags := make(map[string]bool, len(newsIDs))
	for cur.Next(ctx) {
		var row struct {
			NewsID string `bson:"news_id"`
		}
		if err := cur.Decode(&row); err != nil {
			return nil, err
		}
		flags[row.NewsID] = true
	}
	return flags, cur.Err()
}

func (r *BookmarkRepository) ListByUser(ctx context.Context, userID string, page, limit int) ([]entity.Bookmark, int64, int, error) {
	if page < 1 {
		page = 1
	}
	if limit <= 0 || limit > 100 {
		limit = 10
	}
	filter := bson.M{"user_id": userID}
	total, err := r.col.CountDocuments(ctx, filter)
	if err != nil {
		return nil, 0, 0, err
	}
	opts := options.Find().SetSort(bson.D{{Key: "created_at", Value: -1}}).SetSkip(int64((page - 1) * limit)).SetLimit(int64(limit))
	cur, err := r.col.Find(ctx, filter, opts)
	if err != nil {
		return nil, 0, 0, err
	}
	defer cur.Close(ctx)
	var list []entity.Bookmark
	for cur.Next(ctx) {
		var b entity.Bookmark
		if err := cur.Decode(&b); err != nil {
			return nil, 0, 0, err
		}
		list = append(list, b)
	}
	totalPages := int((total + int64(limit) - 1) / int64(limit))
	return list, total, totalPages, cur.Err()
}
