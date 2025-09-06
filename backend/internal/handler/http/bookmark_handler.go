package http

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/handler/http/dto"
	"github.com/gin-gonic/gin"
)

type BookmarkHandler struct {
	uc contract.IBookmarkUsecase
}

func NewBookmarkHandler(uc contract.IBookmarkUsecase) *BookmarkHandler {
	return &BookmarkHandler{uc: uc}
}

// POST /api/v1/me/bookmarks
func (h *BookmarkHandler) Save(c *gin.Context) {
	var req dto.SaveBookmarkRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		ErrorHandler(c, http.StatusBadRequest, err.Error())
		return
	}
	userID := c.GetString("userID")
	if userID == "" {
		ErrorHandler(c, http.StatusUnauthorized, "unauthorized")
		return
	}
	if err := h.uc.Save(c.Request.Context(), userID, req.NewsID); err != nil {
		if errors.Is(err, contract.ErrAlreadyBookmarked) {
			ErrorHandler(c, http.StatusConflict, err.Error())
			return
		}
		ErrorHandler(c, http.StatusInternalServerError, err.Error())
		return
	}
	MessageHandler(c, http.StatusCreated, "bookmarked")
}

// DELETE /api/v1/me/bookmarks/:news_id
func (h *BookmarkHandler) Unsave(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		ErrorHandler(c, http.StatusUnauthorized, "unauthorized")
		return
	}
	newsID := c.Param("news_id")
	if newsID == "" {
		ErrorHandler(c, http.StatusBadRequest, "news_id is required")
		return
	}
	if err := h.uc.Unsave(c.Request.Context(), userID, newsID); err != nil {
		ErrorHandler(c, http.StatusInternalServerError, err.Error())
		return
	}
	MessageHandler(c, http.StatusOK, "unbookmarked")
}

// GET /api/v1/me/bookmarks
func (h *BookmarkHandler) List(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		ErrorHandler(c, http.StatusUnauthorized, "unauthorized")
		return
	}
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	news, total, totalPages, err := h.uc.List(c.Request.Context(), userID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Error: err.Error()})
		return
	}
	// All listed are bookmarked
	flags := map[string]bool{}
	for _, n := range news {
		flags[n.ID] = true
	}
	resp := dto.NewsListResponseDTO{
		News:       dto.MapNewsToDTOsWithBookmarks(news, flags),
		Total:      total,
		TotalPages: totalPages,
		Page:       page,
		Limit:      limit,
	}
	SuccessHandler(c, http.StatusOK, resp)
}
