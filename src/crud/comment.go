package crud

import "db"
import "models"

func GetComments() []models.Comment {
	var comments []models.Comment

	db.DB.Find(&comments)

	return comments
}

func GetComment(commentId uint) *models.Comment {
	var comment models.Comment

	err := db.DB.Take(&comment, "Id = ?", commentId).Error
	if err != nil {
		return nil
	}

	return &comment
}

func GetUserComments(userId uint) []models.Comment {
	var comments []models.Comment

	db.DB.Find(&comments).Where("UserId = ?", userId)

	return comments
}

func GetUserComment(userId uint, commentId uint) *models.Comment {
	var comment models.Comment

	err := db.DB.Take(&comment, "Id = ? AND UserId = ?", commentId, userId).Error
	if err != nil {
		return nil
	}

	return &comment
}

func AddUserComment(comment *models.Comment) bool {
	err := db.DB.Create(comment).Error

	return err == nil
}
