FROM golang:1.27.3 AS build
WORKDIR /src/backend
COPY backend/go.mod backend/go.sum ./
RUN go mod download
COPY backend/ ./
COPY deploy/healthcheck/main.go /src/healthcheck.go
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/moby-api ./cmd/moby-api \
 && CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/healthcheck /src/healthcheck.go \
 && mkdir /data && chown 65532:65532 /data

FROM scratch
COPY --from=build --chown=65532:65532 /out/ /
COPY --from=build --chown=65532:65532 /data/ /data/
USER 65532:65532
ENV MOBY_ADDR=0.0.0.0:8080 MOBY_GRPC_ADDR=0.0.0.0:9090 MOBY_DATABASE=/data/family.sqlite
EXPOSE 8080 9090
HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 CMD ["/healthcheck"]
ENTRYPOINT ["/moby-api"]
