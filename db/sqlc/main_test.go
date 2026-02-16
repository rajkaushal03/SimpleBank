package db

import (
	"context"
	"database/sql"
	"log"
	"os"
	"testing"

	_ "github.com/lib/pq"
)

const (
	dbDriver = "postgres"
	// ✅ IMPORTANT: Use test database, NOT production!
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

	err = testDB.Ping()
	if err != nil {
		log.Fatal("cannot ping db:", err)
	}

	log.Println("✅ Test database connection successful!")

	testQueries = New(testDB)

	// Clean test database before tests
	cleanupDatabase()

	code := m.Run()

	// Clean test database after tests
	// cleanupDatabase()

	testDB.Close()
	os.Exit(code)
}

func cleanupDatabase() {
	ctx := context.Background()

	queries := []string{
		"TRUNCATE TABLE transfers RESTART IDENTITY CASCADE;",
		"TRUNCATE TABLE entries RESTART IDENTITY CASCADE;",
		"TRUNCATE TABLE accounts RESTART IDENTITY CASCADE;",
	}

	for _, query := range queries {
		_, err := testDB.ExecContext(ctx, query)
		if err != nil {
			log.Printf("Warning: cleanup query failed: %v", err)
		}
	}

	log.Println("✅ Test database cleaned!")
}
