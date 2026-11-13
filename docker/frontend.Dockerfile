FROM debian:bookworm-slim AS base

FROM base AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    xz-utils \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ARG FLUTTER_VERSION=3.47.4
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

RUN curl -fSL -o flutter.tar.xz \
  https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz 
RUN mkdir -p ${FLUTTER_HOME}
RUN tar -xf flutter.tar.xz -C /opt
RUN rm flutter.tar.xz

RUN groupadd -g 1000 appgroup && \
    useradd -u 1000 -g appgroup -m -s /bin/bash appuser

WORKDIR /app
COPY --chown=appuser:appgroup ./pubspec* ./
COPY --chown=appuser:appgroup ./web-frontend/lib ./web-frontend/lib
COPY --chown=appuser:appgroup ./web-frontend/web ./web-frontend/web
COPY --chown=appuser:appgroup ./web-frontend/pubspec* ./web-frontend/

RUN chown -R appuser:appgroup /app
USER appuser

WORKDIR /app/web-frontend

RUN flutter pub get
RUN dart run build_runner build
RUN flutter build web --wasm

FROM nginx:alpine AS runner

RUN addgroup --system --gid 1001 groupuser
RUN adduser --system --uid 1001 appuser

COPY --from=builder --chown=appuser:groupuser /app/web-frontend/build/web /usr/share/nginx/html
COPY --chown=appuser:groupuser ./docker/nginx.conf /etc/nginx/conf.d/default.conf

