REPORTER = spec

install :
	@npm install ./
test:
	@./node_modules/mocha/bin/mocha 
start-example:
	@./node_modules/supervisor/lib/cli-wrapper.js  ./examples/server.coffee 
watch-test:
	@./node_modules/mocha/bin/mocha -w
lint:
	@./node_modules/coffeelint/bin/coffeelint -r lib test

.PHONY: test
