IGNORED_PACKAGES := /vendor/

SOURCEDIR=.
SOURCES := $(shell find $(SOURCEDIR) -name '*.go')

BINARY=falcon

d := $(shell date)
branch := $(shell git branch | grep \* | cut -d ' ' -f2)

.DEFAULT_GOAL: $(BINARY)

$(BINARY): $(SOURCES)
	go build -o $(BINARY)

.PHONY: build
build:
	go build -o $(BINARY)

.PHONY: run
run: 
	./$(BINARY) -mp=9991

.PHONY: pull
pull:
	git reset --hard
	git pull origin ${branch}

.PHNOY: push
push: version
	git commit -am "SYNC BIN $d"
	git push origin ${branch}

.PHONY: test
test:
	go vet $(allpackages)
	GODEBUG=cgocheck=2 go test -race $(allpackages)
	# go test $(shell go list ./... | grep -v /vendor/)

.PHONY: list
list:
	@echo $(allpackages)

.PHONY: version
version:
	@git remote -v
	@echo VERSION: $(VERSION)
	@echo branch: $(branch)

.PHNOY: install
install:

DATE             := $(shell date --rfc-3339=seconds)
VERSION          := $(shell git describe --tags --always --dirty="-dev")

# cd into the GOPATH to workaround ./... not following symlinks
_allpackages = $(shell ( cd $(GOPATH)/src/$(IMPORT_PATH) && \
    go list ./... 2>&1 1>&3 | \
    grep -v -e "^$$" $(addprefix -e ,$(IGNORED_PACKAGES)) 1>&2 ) 3>&1 | \
    grep -v -e "^$$" $(addprefix -e ,$(IGNORED_PACKAGES)))

# memoize allpackages, so that it's executed only once and only if used
allpackages = $(if $(__allpackages),,$(eval __allpackages := $$(_allpackages)))$(__allpackages)

