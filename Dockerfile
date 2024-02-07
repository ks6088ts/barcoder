# https://docs.docker.com/develop/develop-images/multistage-build/#name-your-build-stages

FROM golang:1.22 AS builder
WORKDIR /go/src/github.com/ks6088ts/barcoder/
COPY . .
RUN make build GOOS=linux

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/src/github.com/ks6088ts/barcoder/dist/barcoder ./barcoder
CMD ["./barcoder"]
