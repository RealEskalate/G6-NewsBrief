package mongodb

import (
	"context"
	"errors"
	"fmt"
	"log"
	"time"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type UserRepository struct {
	collection *mongo.Collection
}

func NewUserRepository(collection *mongo.Collection) *UserRepository {
	return &UserRepository{collection: collection}
}

func (r *UserRepository) CreateUser(ctx context.Context, user *entity.User) error {
	_, err := r.collection.InsertOne(ctx, user)
	return err
}

func (r *UserRepository) GetUserByID(ctx context.Context, id string) (*entity.User, error) {
	var user entity.User
	err := r.collection.FindOne(ctx, bson.M{"_id": id}).Decode(&user)
	if err != nil {
		return nil, errors.New("user not found")
	}
	return &user, nil
}

func (r *UserRepository) GetUserByEmail(ctx context.Context, email string) (*entity.User, error) {
	var user entity.User
	err := r.collection.FindOne(ctx, bson.M{"email": email}).Decode(&user)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("user not found")
		}
		return nil, err
	}
	return &user, nil
}

// func (r *UserRepository) GetUserByUsername(ctx context.Context, username string) (*entity.User, error) {
// 	var user entity.User
// 	err := r.collection.FindOne(ctx, bson.M{"username": username}).Decode(&user)
// 	if err != nil {
// 		if err == mongo.ErrNoDocuments {
// 			return nil, errors.New("user not found")
// 		}
// 		return nil, err
// 	}
// 	return &user, nil
// }

// func (r *UserRepository) GetByUserName(ctx context.Context, username string) (*entity.User, error) {
// 	var user entity.User
// 	err := r.collection.FindOne(ctx, bson.M{"username": username}).Decode(&user)
// 	if err != nil {
// 		return nil, errors.New("user not found")
// 	}
// 	return &user, nil
// }

// UpdateUser updates an existing user and returns the updated user
func (r *UserRepository) UpdateUser(ctx context.Context, user *entity.User) (*entity.User, error) {
	user.UpdatedAt = time.Now()
	filter := bson.M{"_id": user.ID}
	update := bson.M{"$set": user}
	result, err := r.collection.UpdateOne(ctx, filter, update)
	if err != nil {
		log.Printf("UpdateOne error: %v", err)
		return nil, err
	}
	if result.MatchedCount == 0 {
		return nil, errors.New("user not found")
	}
	var updatedUser entity.User
	if err := r.collection.FindOne(ctx, filter).Decode(&updatedUser); err != nil {
		return nil, err
	}
	return &updatedUser, nil
}

func (r *UserRepository) UpdateUserPassword(ctx context.Context, id string, hashedPassword string) error {
	filter := bson.M{"_id": id}
	update := bson.M{"$set": bson.M{"password_hash": hashedPassword}}
	count, err := r.collection.UpdateOne(ctx, filter, update)
	if err != nil {
		return err
	}

	if count.MatchedCount == 0 {
		return fmt.Errorf("failed to fetch user with id:%s", id)
	}
	return nil
}

func (r *UserRepository) DeleteUser(ctx context.Context, id string) error {
	filter := bson.M{"_id": id}
	count, err := r.collection.DeleteOne(ctx, filter)
	if err != nil {
		return err
	}
	if count.DeletedCount == 0 {
		return fmt.Errorf("failed to fetch user with id:%s", id)
	}
	return nil
}

// AddSubscription adds a source slug to the user's embedded list of subscriptions.
// It uses $addToSet to automatically prevent duplicates.
func (r *UserRepository) AddSourceSubscription(ctx context.Context, id string, sourceSlug string) error {
	filter := bson.M{"_id": id}
	// Ensure the array field exists as an array before $addToSet to avoid "non-array type null"
	if err := r.ensureArrayField(ctx, id, "preferences.subscribed_sources"); err != nil {
		return err
	}
	update := bson.M{
		"$addToSet": bson.M{"preferences.subscribed_sources": sourceSlug},
	}

	result, err := r.collection.UpdateOne(ctx, filter, update)
	if err != nil {
		return err
	}

	if result.MatchedCount == 0 {
		return errors.New("user not found")
	}
	return nil
}

// RemoveSubscription removes a source slug from the user's embedded list of subscriptions.
func (r *UserRepository) RemoveSourceSubscription(ctx context.Context, id string, sourceSlug string) error {
	filter := bson.M{"_id": id}
	if err := r.ensureArrayField(ctx, id, "preferences.subscribed_sources"); err != nil {
		return err
	}
	update := bson.M{
		"$pull": bson.M{"preferences.subscribed_sources": sourceSlug},
	}

	result, err := r.collection.UpdateOne(ctx, filter, update)
	if err != nil {
		return err
	}

	if result.MatchedCount == 0 {
		return errors.New("user not found")
	}
	return nil
}

// GetSubscriptions retrieves only the list of subscribed source slugs for a user.
// This uses a projection for efficiency, so the entire user document is not fetched.
func (r *UserRepository) GetSourceSubscriptions(ctx context.Context, id string) ([]string, error) {
	// Local struct for decoding only the field we need.
	var result struct {
		Preferences struct {
			SubscribedSources []string `bson:"subscribed_sources"`
		} `bson:"preferences"`
	}

	filter := bson.M{"_id": id}
	projection := bson.M{"preferences.subscribed_sources": 1, "_id": 0}
	opts := options.FindOne().SetProjection(projection)

	if err := r.collection.FindOne(ctx, filter, opts).Decode(&result); err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("user not found")
		}
		return nil, err
	}

	// Return an empty slice if the field is null or missing, which is the correct behavior.
	return result.Preferences.SubscribedSources, nil
}

/* func (r *UserRepository) SubscribeTopic(ctx context.Context, userID, topicID string) error {
	filter := bson.M{"_id": userID}
	if err := r.ensureArrayField(ctx, userID, "preferences.topics"); err != nil {
		return err
	}
	update := bson.M{
		"$addToSet": bson.M{"preferences.topics": topicID},
	}
	count, err := r.collection.UpdateOne(ctx, filter, update)
	if err != nil {
		return err
	}
	if res.MatchedCount == 0 {
		return errors.New("user not found")
	}
	return nil
}
*/
// UnsubscribeTopic pulls a topic from preferences.topics
func (r *UserRepository) UnsubscribeTopic(ctx context.Context, userID, topicID string) error {
	filter := bson.M{"_id": userID}
	if err := r.ensureArrayField(ctx, userID, "preferences.topics"); err != nil {
		return err
	}
	update := bson.M{
		"$pull": bson.M{"preferences.topics": topicID},
	}
	res, err := r.collection.UpdateOne(ctx, filter, update)
	if err != nil {
		return err
	}
	if res.MatchedCount == 0 {
		return errors.New("user not found")
	}
	return nil
}

// SubscribeTopics adds multiple topics to preferences.topics using $addToSet + $each
func (r *UserRepository) SubscribeTopics(ctx context.Context, userID string, topicIDs []string) error {
	if len(topicIDs) == 0 {
		return nil
	}
	filter := bson.M{"_id": userID}
	if err := r.ensureArrayField(ctx, userID, "preferences.topics"); err != nil {
		return err
	}
	update := bson.M{
		"$addToSet": bson.M{
			"preferences.topics": bson.M{"$each": topicIDs},
		},
	}
	res, err := r.collection.UpdateOne(ctx, filter, update)
	if err != nil {
		return err
	}
	if res.MatchedCount == 0 {
		return errors.New("user not found")
	}
	return nil
}

func (r *UserRepository) GetUserSubscribedTopicsByID(ctx context.Context, userID string) ([]string, error) {
	filter := bson.M{"_id": userID}
	projection := bson.M{"preferences.topics": 1, "_id": 0}
	opts := options.FindOne().SetProjection(projection)

	var result struct {
		Preferences struct {
			Topics []string `bson:"topics"`
		} `bson:"preferences"`
	}

	if err := r.collection.FindOne(ctx, filter, opts).Decode(&result); err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("user not found")
		}
		return nil, err
	}

	return result.Preferences.Topics, nil
}

// ensureArrayField initializes a nested array field to an empty array when it is missing or null.
func (r *UserRepository) ensureArrayField(ctx context.Context, userID string, field string) error {
	filter := bson.M{
		"_id": userID,
		"$or": bson.A{
			bson.M{field: bson.M{"$exists": false}},
			bson.M{field: bson.M{"$type": 10}}, // null
		},
	}
	update := bson.M{"$set": bson.M{field: bson.A{}}}
	_, err := r.collection.UpdateOne(ctx, filter, update)
	if err != nil {
		return err
	}
	return nil
}
