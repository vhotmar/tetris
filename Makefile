.PHONY: all
all:
	mkdir -p ./build
	fpc application.pas

.PHONY: clean
clean:
	rm -Rf ./build/
	rm -f ./application
