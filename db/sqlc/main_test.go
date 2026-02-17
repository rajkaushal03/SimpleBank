package db

import (
	"SimpleBank/util"
	"database/sql"
	"log"
	"os"
	"testing"

	_ "github.com/lib/pq"
)

var testQueries *Queries
var testDB *sql.DB

func TestMain(m *testing.M) {
	config, err := util.LoadConfig("../..")

	if err != nil {
		log.Fatal("cannot load config: ", err)
	}

	testDB, err = sql.Open(config.DBDriver, config.DBSource)
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
	// cleanupDatabase()

	code := m.Run()

	// Clean test database after tests

	testDB.Close()
	os.Exit(code)
}
