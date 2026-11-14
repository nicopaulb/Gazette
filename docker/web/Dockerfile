# Build context: repository root (see docker-compose.yml)
# Version used to validate the build (pubspec.lock requires Flutter >= 3.35.1)
ARG FLUTTER_VERSION=3.38.10

FROM ghcr.io/cirruslabs/flutter:${FLUTTER_VERSION} AS build
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
# Public URL of PocketBase, compiled into the app (e.g. https://gazette.example.com)
ARG DB_URL
RUN test -n "$DB_URL" || (echo "DB_URL build arg is required" && exit 1)
RUN flutter build web --release --dart-define DB_URL=$DB_URL

FROM caddy:2-alpine
COPY docker/web/Caddyfile /etc/caddy/Caddyfile
COPY --from=build /app/build/web /srv
EXPOSE 80
