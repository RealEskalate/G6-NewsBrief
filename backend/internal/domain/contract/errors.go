package contract

import "errors"

// Shared domain-level errors
var (
	// ErrAlreadyBookmarked indicates the user already bookmarked the given news
	ErrAlreadyBookmarked = errors.New("already bookmarked")
)
