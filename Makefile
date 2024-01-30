.PHONY: help all docker run test load-test linux windows

help :
	@echo "Usage:"
	@echo "   make all         - build, run and test secrets"
	@echo ""
	@echo "   make docker      - build a Secrets docker image"
	@echo ""
	@echo "   make run         - run Secrets from docker image"
	@echo "   make test        - run a test against Secrets docker image"

all : docker run test

docker :
	docker build . -t secrets

run :
	docker run -it --rm --name secrets -p 8080:8080 -v "${PWD}/secretsvol":/secretsvol secrets

test :
	@cd webv && webv --server http://localhost:8080 --files secrets.json --verbose --verbose-errors
