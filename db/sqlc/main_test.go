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

	log.Println("Database connection successful!")

	testQueries = New(testDB)

	// Clean up before running tests
	cleanupDatabase()

	code := m.Run()

	// Clean up after running tests
	cleanupDatabase()

	testDB.Close()
	os.Exit(code)
}

func cleanupDatabase() {
	ctx := context.Background()

	// Disable foreign key checks temporarily
	testDB.ExecContext(ctx, "SET session_replication_role = 'replica';")

	// Truncate all tables
	testDB.ExecContext(ctx, "TRUNCATE TABLE transfers CASCADE;")
	testDB.ExecContext(ctx, "TRUNCATE TABLE entries CASCADE;")
	testDB.ExecContext(ctx, "TRUNCATE TABLE accounts CASCADE;")

	// Re-enable foreign key checks
	testDB.ExecContext(ctx, "SET session_replication_role = 'origin';")

	log.Println("Database cleaned up!")
}
