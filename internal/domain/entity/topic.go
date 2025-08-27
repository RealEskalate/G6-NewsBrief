package entity

// BilingualField represents a field with both English and Amharic translations.
type BilingualField struct {
	EN string `bson:"en" json:"en"`
	AM string `bson:"am" json:"am"`
}

// Topic represents a news category.
type Topic struct {
	ID          string         `bson:"_id,omitempty" json:"id"`
	Key         string         `bson:"key" json:"key"`
	Label       BilingualField `bson:"label" json:"label"`
	Description BilingualField `bson:"description" json:"description"`
	ImageURL    string         `bson:"image_url" json:"image_url"`
	StoryCount  int            `bson:"story_count" json:"story_count"`
	SortOrder   int            `bson:"sort_order" json:"-"`
}
