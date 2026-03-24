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

# Docker Compose container name
COMPOSE_POSTGRES := simplebank_postgres_1

# Production Database (standalone)
postgres:
	$(DOCKER_SUDO) docker run --name postgres12 --network bank-network -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:12-alpine

createdb:
	$(DOCKER_SUDO) docker exec $(DOCKER_IT) postgres12 createdb --username=root --owner=root simplebank

dropdb:
	$(DOCKER_SUDO) docker exec $(DOCKER_IT) postgres12 dropdb simplebank

checkdb:
	$(DOCKER_SUDO) docker exec $(DOCKER_IT) postgres12 psql -U root -d simplebank

listdb:
	$(DOCKER_SUDO) docker exec $(DOCKER_IT) postgres12 psql -U root -l

# Docker Compose targets (NEW)
dc-up:
	docker-compose up -d

dc-down:
	docker-compose down

dc-build:
	docker-compose build --no-cache

dc-logs:
	docker-compose logs -f

dc-checkdb:
	$(DOCKER_SUDO) docker exec $(DOCKER_IT) $(COMPOSE_POSTGRES) psql -U root -d simplebank

dc-listdb:
	$(DOCKER_SUDO) docker exec $(DOCKER_IT) $(COMPOSE_POSTGRES) psql -U root -l

dc-createdb:
	$(DOCKER_SUDO) docker exec $(DOCKER_IT) $(COMPOSE_POSTGRES) createdb --username=root --owner=root simplebank

dc-dropdb:
	$(DOCKER_SUDO) docker exec $(DOCKER_IT) $(COMPOSE_POSTGRES) dropdb simplebank

dc-cleandb:
	$(DOCKER_SUDO) docker exec $(DOCKER_IT) $(COMPOSE_POSTGRES) psql -U root -d simplebank -c "TRUNCATE TABLE transfers, entries, accounts, users RESTART IDENTITY CASCADE;"

migrateup:
	$(MIGRATE_UP)

migratedown:
	$(MIGRATE_DOWN)

migrateversiondown:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simplebank?sslmode=disable" -verbose down 1

checkmigrateversion:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simplebank?sslmode=disable" -verbose version

migrateup1:
	$(MIGRATE_UP) 1

migratedown1:
	$(MIGRATE_DOWN) 1

sqlc:
	sqlc generate

test:
	go test -v -cover ./...

cleandb:
	$(DOCKER_SUDO) docker exec $(DOCKER_IT) postgres12 psql -U root -d simplebank -c "TRUNCATE TABLE transfers, entries, accounts, users RESTART IDENTITY CASCADE;"

server:
	air

# Script-based commands
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

mock:
	mockgen -package mockdb -destination db/mock/store.go SimpleBank/db/sqlc Store

.PHONY: postgres createdb dropdb checkdb migrateup migratedown sqlc test cleandb \
		listdb install cleanup reset status softclean server mock migratedown1 migrateup1 \
		migrateversiondown checkmigrateversion dc-up dc-down dc-build dc-logs dc-checkdb \
		dc-listdb dc-createdb dc-dropdb dc-cleandb