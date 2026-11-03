import { serve } from "@hono/node-server";
import { Hono } from "hono";
import { openAPIRouteHandler } from "hono-openapi";
import { logger } from "hono/logger";
import entryRouter from "./routers/entry.js";

const app = new Hono();

app.use(logger());

app.get(
  "/openapi",
  openAPIRouteHandler(app, {
    documentation: {
      info: {
        title: "web-journal backend",
        version: "1.0.0",
      },
      servers: [{ url: "http://localhost:3000" }],
    },
  }),
);

app.route("/api/entry", entryRouter);

serve(
  {
    fetch: app.fetch,
    port: 3000,
  },
  (info) => {
    console.log(`Server is running on http://localhost:${info.port}`);
  },
);
