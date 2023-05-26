FROM golang:alpine as golangconsuldiscovery
RUN addgroup -S golangconsuldiscovery \
  && adduser -S -u 10000 -g golangconsuldiscovery golangconsuldiscovery
WORKDIR /go/src/app
COPY . .
RUN CGO_ENABLED=0 go install -ldflags '-extldflags "-static"' -tags timetzdata
RUN echo ${PWD} && ls -lR

FROM scratch
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=golangconsuldiscovery /go/bin/golangconsuldiscovery /golangconsuldiscovery
COPY --from=golangconsuldiscovery /etc/passwd /etc/passwd
USER golangconsuldiscovery
ENTRYPOINT ["/golangconsuldiscovery"]