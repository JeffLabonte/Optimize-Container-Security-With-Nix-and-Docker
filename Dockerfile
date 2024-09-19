FROM golang:1.23-alpine

EXPOSE 8080

WORKDIR /app

RUN apk upgrade --update

COPY ./src/ /app/
RUN go build -o server .

RUN mv server /usr/bin/ && \
    rm /app/*

ENTRYPOINT [ "server" ]
