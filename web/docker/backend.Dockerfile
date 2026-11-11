FROM node:24-alpine AS base
FROM base AS builder

COPY --from=ghcr.io/pnpm/pnpm:12-alpine /opt/pnpm /opt/pnpm
RUN for bin in pnpm pn pnpx pnx; do ln -s "/opt/pnpm/$bin" "/usr/local/bin/$bin"; done

RUN apk add --no-cache gcompat

WORKDIR /app
COPY pnpm-lock.yaml pnpm-workspace.yaml ./

WORKDIR /app/backend
COPY backend/package.json backend/tsconfig.json ./
COPY backend/src ./src

RUN pnpm install
RUN pnpm run build
RUN pnpm prune --production

FROM base AS runner
WORKDIR /app

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 hono

COPY --from=builder --chown=hono:nodejs /app/node_modules /app/node_modules
COPY --from=builder --chown=hono:nodejs /app/pnpm-lock.yaml /app/backend/pnpm-lock.yaml
COPY --from=builder --chown=hono:nodejs /app/pnpm-workspace.yaml /app/backend/pnpm-workspace.yaml
COPY --from=builder --chown=hono:nodejs /app/backend/dist /app/backend/dist
COPY --from=builder --chown=hono:nodejs /app/backend/package.json /app/backend/package.json
COPY --from=builder --chown=hono:nodejs /app/backend/node_modules /app/backend/node_modules

USER hono
EXPOSE 3000

CMD ["node", "/app/backend/dist/index.js"]
