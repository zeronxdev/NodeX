# Build go
FROM golang:1.22.0-alpine AS builder
WORKDIR /app
COPY . .
ENV CGO_ENABLED=0
RUN go mod download \
    && go build -v -o NodeX -trimpath -ldflags "-s -w -buildid="

# Release
FROM alpine:latest
# 安装必要的工具包
RUN apk --update --no-cache add curl tzdata ca-certificates \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && mkdir /etc/NodeX/ \
    && curl -L "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat" -o /etc/NodeX/geoip.dat \
    && curl -L "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat" -o /etc/NodeX/geosite.dat

COPY --from=builder /app/NodeX /usr/local/bin

ENTRYPOINT [ "NodeX", "--config", "/etc/NodeX/config.yml"]
