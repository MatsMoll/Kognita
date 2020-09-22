FROM swift:5.2
WORKDIR /app
COPY . .
ENV BUILD_TYPE DEV
RUN swift package clean
RUN swift build -c release
RUN mkdir /app/bin
RUN mv `swift build -c release --show-bin-path` /app/bin 
EXPOSE 8080
ENTRYPOINT ./bin/release/Run serve --env local --hostname 0.0.0.0