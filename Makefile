.PHONY: all
all:
	mkdir ./build
	fpc application.pas

.PHONY: clean
clean:
	rm -Rf ./build/
	rm -f ./application
