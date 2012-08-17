REPORTER = spec

install :
	@npm install ./
test:
	@./node_modules/mocha/bin/mocha 

watch-test:
	@./node_modules/mocha/bin/mocha -w

.PHONY: test
