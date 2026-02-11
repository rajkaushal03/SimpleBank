package db

import (
	"database/sql"
	"log"
	"os"
	"testing"

	_ "github.com/lib/pq"
)

const (
	dbDriver = "postgres"
	dbSource = "postgresql://root:secret@localhost:5432/simplebank?sslmode=disable"
)

var testQueries *Queries
var testDB *sql.DB

func TestMain(m *testing.M) {
	var err error

	testDB, err = sql.Open(dbDriver, dbSource)
	if err != nil {
		log.Fatal("cannot open db connection:", err)
	}

	// Test the connection
	err = testDB.Ping()
	if err != nil {
		log.Fatal("cannot ping db:", err)
	}

	log.Println("Database connection successful!")

	testQueries = New(testDB)

	code := m.Run()

	testDB.Close()
	os.Exit(code)
}
