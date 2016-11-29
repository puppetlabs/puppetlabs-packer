
test: deps
	@echo running tests
	@tests/test-syntax.sh

deps: packer

packer:
	@tests/test-setup.sh

clean:
	rm -f packer

