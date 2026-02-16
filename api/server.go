package api

import (
	db "SimpleBank/db/sqlc"

	"github.com/gin-gonic/gin"
)

// servers serve http request for our banking service
type Server struct {
	store  *db.Store
	router *gin.Engine
}

// NewServer create new HTTP server and setup routing
func NewServer(store *db.Store) *Server {
	server := &Server{store: store}
	router := gin.Default()

	router.POST("/accounts", server.createAccount)
	router.GET("/accounts/:id", server.getAccount)
	router.GET("/accounts", server.listAccount)

	server.router = router
	return server
}

// starts run the http server on specific address
func (server *Server) Start(address string) error {
	return server.router.Run(address)
}

func errorResponse(err error) gin.H {
	return gin.H{"error": err.Error()}
}
