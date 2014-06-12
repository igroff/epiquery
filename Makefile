.PHONY: start stop status test setup clean environment profile start_managed start-managed watch
SHELL=/usr/bin/env bash

status: setup
	./bin/status
start: setup
	./bin/start
watch:
	./node_modules/.bin/supervisor -w bin -e coffee,js -x make start-managed
start_managed: setup
	exec ./bin/start managed
start-managed: setup
	exec ./bin/start managed
profile: setup
	./bin/start profile
stop: setup
	./bin/stop
test: setup
	cd ./test && ./run_old.sh
	./test/run.sh

setup: var/log node_modules var/run environment
	echo "setup complete"

environment:
	./bin/setup-environment

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
	source bin/setup-environment && npm install  
