# Detect OS and set appropriate commands
ifeq ($(OS),Windows_NT)
	DOCKER_SUDO :=
	DOCKER_IT := -i
else
	DOCKER_SUDO := sudo
	DOCKER_IT := -it
endif

# Use local migrate binary on both platforms
MIGRATE_UP := migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simplebank?sslmode=disable" -verbose up
MIGRATE_DOWN := migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simplebank?sslmode=disable" -verbose down
MIGRATE_UP_TEST := migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simplebank_test?sslmode=disable" -verbose up
MIGRATE_DOWN_TEST := migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simplebank_test?sslmode=disable" -verbose down

# test Database
createtestdb:
	$(DOCKER_SUDO) docker exec $(DOCKER_IT) postgres12 createdb --username=root --owner=root simplebank_test

droptestdb:
	$(DOCKER_SUDO) docker exec $(DOCKER_IT) postgres12 dropdb simplebank_test

migrateuptestdb:
	$(MIGRATE_UP_TEST)

migratedowntestdb:
	$(MIGRATE_DOWN_TEST)

checktestdb:
	$(DOCKER_SUDO) docker exec $(DOCKER_IT) postgres12 psql -U root -d simplebank_test

testscript:
	./scripts/test.sh

# production Database
postgres:
	$(DOCKER_SUDO) docker run --name postgres12 -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:12-alpine

createdb:
	$(DOCKER_SUDO) docker exec $(DOCKER_IT) postgres12 createdb --username=root --owner=root simplebank

dropdb:
	$(DOCKER_SUDO) docker exec $(DOCKER_IT) postgres12 dropdb simplebank

checkdb:
	$(DOCKER_SUDO) docker exec $(DOCKER_IT) postgres12 psql -U root -d simplebank

listdb:
	$(DOCKER_SUDO) docker exec $(DOCKER_IT) postgres12 psql -U root -l

migrateup:
	$(MIGRATE_UP)

migratedown:
	$(MIGRATE_DOWN)

sqlc:
	sqlc generate

test:
	go test -v -cover ./db/sqlc

cleandb:
	$(DOCKER_SUDO) docker exec $(DOCKER_IT) postgres12 psql -U root -d simplebank -c "TRUNCATE TABLE transfers, entries, accounts RESTART IDENTITY CASCADE;"

# Script-based commands (NEW)
install:
	./scripts/install.sh

cleanup:
	./scripts/cleanup.sh

reset:
	./scripts/reset.sh

status:
	./scripts/status.sh

softclean:
	./scripts/softclean.sh

.PHONY: postgres createdb dropdb checkdb migrateup migratedown sqlc test cleandb \
		createtestdb droptestdb migrateuptestdb migratedowntestdb checktestdb testscript \
		listdb install cleanup reset status softclean