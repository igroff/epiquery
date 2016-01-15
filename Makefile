.PHONY: start stop status test setup clean environment profile start_managed start-managed
SHELL=/usr/bin/env bash

status: setup
	./bin/status
start: setup
	./bin/start
start_managed: setup
	exec ./bin/start managed
start-managed: setup
	exec ./bin/start managed
profile: setup
	./bin/start profile
stop: setup
	./bin/stop
test/templates:
	cd test
	git clone https://github.com/igroff/epiquery-templates.git templates
test: setup
	cd ./test && ./run_old.sh
	difftest run

setup: var/log node_modules var/run environment test/templates
	echo "setup complete"

environment:
	./bin/setup-environment

clean:
	@rm -rf node_modules/

var/log:
	mkdir -p $(CURDIR)/var/log

var/run:
	mkdir -p $(CURDIR)/var/run

node_modules: 
	source bin/setup-environment && npm install  
