# build the app
FROM golang:latest as build

ARG Version=0.1.0

COPY src/main.go .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-X main.Version=$Version-$(date +%m%d-%H%M)" -a -installsuffix cgo -o ./secrets main.go

## create the image
FROM scratch

WORKDIR /
EXPOSE 8080
ENTRYPOINT [ "./secrets" ]

COPY --from=build /go/secrets /
COPY ./src/secretsvol /secretsvol
