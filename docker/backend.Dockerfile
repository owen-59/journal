FROM node:24-alpine AS base
FROM base AS builder

COPY --from=ghcr.io/pnpm/pnpm:12-alpine /opt/pnpm /opt/pnpm
RUN for bin in pnpm pn pnpx pnx; do ln -s "/opt/pnpm/$bin" "/usr/local/bin/$bin"; done

RUN apk add --no-cache gcompat

WORKDIR /app
COPY pnpm-lock.yaml pnpm-workspace.yaml ./

COPY pnpm-*.yaml .
COPY web-backend/package.json web-backend/tsconfig.json ./web-backend/
COPY web-backend/src ./web-backend/src

WORKDIR /app/web-backend

RUN pnpm install
RUN pnpm run build
RUN pnpm prune --production

FROM base AS runner
WORKDIR /app

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 hono

COPY --from=builder --chown=hono:nodejs /app/web-backend/node_modules /app/web-backend/node_modules
COPY --from=builder --chown=hono:nodejs /app/node_modules /app/node_modules
COPY --from=builder --chown=hono:nodejs /app/pnpm-lock.yaml /app/pnpm-lock.yaml
COPY --from=builder --chown=hono:nodejs /app/pnpm-workspace.yaml /app/pnpm-workspace.yaml
COPY --from=builder --chown=hono:nodejs /app/web-backend/dist /app/web-backend/dist
COPY --from=builder --chown=hono:nodejs /app/web-backend/package.json /app/web-backend/package.json
COPY --from=builder --chown=hono:nodejs /app/web-backend/node_modules /app/web-backend/node_modules

USER hono
EXPOSE 3000

CMD ["node", "/app/web-backend/dist/index.js"]
