# test Database
createtestdb:
	sudo docker exec -it postgres12 createdb --username=root --owner=root simplebank_test

droptestdb:
	sudo docker exec -it postgres12 dropdb simplebank_test

migrateuptestdb:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simplebank_test?sslmode=disable" -verbose up

migratedowntestdb:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simplebank_test?sslmode=disable" -verbose down

checktestdb:
	sudo docker exec -it postgres12 psql -U root -d simplebank_test

testscript:
	./scripts/test.sh

# priduction Database
postgres:
	sudo docker run --name postgres12 -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:12-alpine

createdb: 
	sudo docker exec -it postgres12 createdb --username=root --owner=root simplebank

dropdb:
	sudo docker exec -it postgres12 dropdb simplebank

checkdb:
	sudo docker exec -it postgres12 psql -U root -d simplebank

listdb:
	sudo docker exec -it postgres12 psql -U root -l

migrateup:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simplebank?sslmode=disable" -verbose up

migratedown:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simplebank?sslmode=disable" -verbose down

sqlc:
	sqlc generate

test:
	go test -v -cover ./db/sqlc

cleandb:
	sudo docker exec -it postgres12 psql -U root -d simplebank -c "TRUNCATE TABLE transfers, entries, accounts RESTART IDENTITY CASCADE;"

.PHONY: postgres createdb dropdb checkdb migrateup migratedown sqlc test cleandb createtestdb droptestdb migrateuptestdb migratedowntestdb checktestdb testscript listdb
