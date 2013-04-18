.PHONY: start stop status test setup nuke clean
SHELL=/usr/bin/env bash

status: setup
	./bin/status
start: setup
	./bin/start
stop: setup
	./bin/stop
test: setup
	cd ./test && ./run.sh

setup: var/log node_modules var/run
	echo "setup complete"

nuke:
	@rm -rf var/log
	@rm -rf node_modules/
	@rm -rf var/run

clean:
	@rm -rf node_modules/

var/log:
	mkdir -p $(CURDIR)/var/log

var/run:
	mkdir -p $(CURDIR)/var/run

node_modules: 
	npm install  
