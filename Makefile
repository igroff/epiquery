.PHONY: watch start

watch: ./node_modules
	DEBUG=true exec ./node_modules/.bin/supervisor --watch "lib/,." --extensions .coffee --exec $(shell which bash) bin/start

start: ./node_modules
	bin/start ${PORT}

./node_modules:
	npm install .


