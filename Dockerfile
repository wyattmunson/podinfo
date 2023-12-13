FROM golang:1.21-alpine as builder

ARG REVISION

WORKDIR /podinfo

RUN go mod download


RUN CGO_ENABLED=0 go build -ldflags "-s -w \
  -X github.com/stefanprodan/podinfo/pkg/version.REVISION=${REVISION}" \
  -a -o bin/podinfo cmd/podinfo/*


RUN CGO_ENABLED=0 go build -ldflags "-s -w \
  -X github.com/stefanprodan/podinfo/pkg/version.REVISION=${REVISION}" \
  -a -o bin/podcli cmd/podcli/*


FROM alpine:3.18

ARG BUILD_DATE
ARG VERSION
ARG REVISION

LABEL maintainer="stefanprodan"

RUN addgroup -S app && adduser -S -G app app

WORKDIR /home/app


COPY --from=builder /podinfo/bin/podinfo .

COPY --from=builder /podinfo/bin/podcli /usr/local/bin/podcli

COPY --from=builder ./ui ./ui

RUN chown -R app:app ./

USER app

CMD ["./podinfo"]
