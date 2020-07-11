FROM golang:alpine as builder

ARG SOURCE_REPO=github.com/bugficks/docker-gen

RUN apk add --no-cache \
    git \
    make \
    gcc \
    libc-dev

RUN go get ${SOURCE_REPO}
WORKDIR src/${SOURCE_REPO}

COPY . /build
WORKDIR /build

RUN make get-deps
# Tests are disabled here because docker build servers are too slow for ms dependent tests
RUN make all check-gofmt
RUN cp docker-gen /

FROM alpine:latest
LABEL maintainer="github.com/bugficks/docker-gen"

RUN apk --no-cache add openssl

ENV DOCKER_HOST unix:///tmp/docker.sock

COPY --from=builder /docker-gen /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/docker-gen"]
