FROM golang:1.24 AS builder

ARG GITHUB_REPO=github.com/dgeorgievski/go-app-6
ARG VERSION="dev"
ARG COMMIT="none"
ARG BUILD_UNIX_TIME=$(date +%s%M)

WORKDIR /app

COPY . .

RUN go mod download

RUN CGO_ENABLED=0 \
    go build \
    -ldflags " -s -w \
        -X ${GITHUB_REPO}/pkg/version.VERSION=${VERSION} \
        -X ${GITHUB_REPO}/pkg/version.COMMIT=${COMMIT} \
        -X ${GITHUB_REPO}/pkg/version.DATE=${BUILD_UNIX_TIME}" \
    -tags netgo,osusergo -a -o bin/go-app-6

FROM scratch

COPY --from=builder /app/bin/go-app-6 /go-app-6

EXPOSE 8080

CMD ["/go-app-6", "server" ]
