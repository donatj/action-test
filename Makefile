BIN=helloworld
HEAD=$(shell ([ -n "$${CI_TAG}" ] && echo "$$CI_TAG" || exit 1) || git describe --tags 2> /dev/null || git rev-parse --short HEAD)
DIRTY=$(shell test $(shell git status --porcelain | wc -l) -eq 0 || echo '(dirty)')

build: darwin_amd64 darwin_arm64 linux_amd64

clean:
	-rm -rf release
	go clean -i .

darwin_amd64:
	env GOOS=darwin GOARCH=amd64 go clean -i .
	env GOOS=darwin GOARCH=amd64 go build -o release/darwin_amd64/$(BIN) .

darwin_arm64:
	env GOOS=darwin GOARCH=arm64 go clean -i .
	env GOOS=darwin GOARCH=arm64 go build -o release/darwin_arm64/$(BIN) .

linux_amd64:
	env GOOS=linux GOARCH=amd64 go clean -i
	env GOOS=linux GOARCH=amd64 go build -o release/linux_amd64/$(BIN) .

.PHONY: release
release: clean build
	mkdir release/dist
	tar -czf 'release/dist/$(BIN).darwin_amd64.$(HEAD)$(DIRTY).tar.gz' release/darwin_amd64/$(BIN)
	tar -czf 'release/dist/$(BIN).darwin_arm64.$(HEAD)$(DIRTY).tar.gz' release/darwin_arm64/$(BIN)
	tar -czf 'release/dist/$(BIN).linux_amd64.$(HEAD)$(DIRTY).tar.gz'  release/linux_amd64/$(BIN)
