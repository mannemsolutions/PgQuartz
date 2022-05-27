uname_p := $(shell uname -p) # store the output of the command in a variable

build: build_pgquartz

build_pgquartz:
	./set_version.sh
	go mod tidy
	go build -o ./bin/pgquartz.$(uname_p) ./cmd/pgquartz

build_dlv:
	go get github.com/go-delve/delve/cmd/dlv@latest
	go build -o /bin/dlv.$(uname_p) github.com/go-delve/delve/cmd/dlv

# Use the following on m1:
# alias make='/usr/bin/arch -arch arm64 /usr/bin/make'
debug:
	go build -gcflags "all=-N -l" -o ./bin/pgquartz.debug.$(uname_p) ./cmd/pgquartz
	~/go/bin/dlv --headless --listen=:2345 --api-version=2 --accept-multiclient exec ./bin/pgquartz.debug.$(uname_p) -- -c jobs/jobspec1/job.yml

run:
	./bin/pgquartz.$(uname_p) -c jobs/jobspec1/job.yml

fmt:
	gofmt -w .
	goimports -w .
	gci write .

compose:
	./docker-compose-tests.sh

test: sec lint

sec:
	gosec ./...
lint:
	golangci-lint run
