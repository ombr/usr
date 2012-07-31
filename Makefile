REPORTER = spec

install :
	@npm install ./
test:
	@./node_modules/mocha/bin/mocha 

.PHONY: test
