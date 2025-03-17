DB_HOST := "127.0.0.1"
DB_USER := "dbuser"
VERSION := "v23.2.21"

init:
	@cockroach cert create-ca \
	--certs-dir=certs \
	--ca-key=ca.key
	@cockroach cert create-node \
	localhost \
	{{DB_HOST}} \
	--certs-dir=certs \
	--ca-key=ca.key
	@cockroach cert create-client \
	root \
	--certs-dir=certs \
	--ca-key=ca.key

add-user:
	@cockroach cert create-client \
	{{DB_USER}} \
	--certs-dir=certs \
	--ca-key=ca.key

list-certs:
	@cockroach cert list --certs-dir=certs

start:
	@docker compose up -d

stop:
	@docker compose down

cleanup:
	@rm ./certs/*
	@rm ca.key

hard-cleanup: cleanup
	@sudo rm -rf ./dbdata

install-cli:
	@wget https://binaries.cockroachdb.com/cockroach-{{VERSION}}.linux-amd64.tgz -P /tmp
	@tar -xvzf /tmp/cockroach-{{VERSION}}.linux-amd64.tgz -C /tmp
	@sudo install /tmp/cockroach-{{VERSION}}.linux-amd64/cockroach /usr/local/bin
	@rm /tmp/cockroach-{{VERSION}}.linux-amd64.tgz
	@rm -rf /tmp/cockroach-{{VERSION}}.linux-amd64

push-image:
	@docker pull cockroachdb/cockroach:{{VERSION}}
	@docker tag cockroachdb/cockroach:{{VERSION}} regv2.gsingh.io/core/cockroachdb/cockroach:{{VERSION}}
	@docker push regv2.gsingh.io/core/cockroachdb/cockroach:{{VERSION}}
