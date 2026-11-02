import { Hono } from "hono";
import { describeRoute, resolver, validator } from "hono-openapi";
import { Entry, EntryQuery } from "../schemas.js";

const app = new Hono();

app.get(
  "/:year/:month/:day/:hour/:minute",
  describeRoute({
    description: "Get entry at some datetime",
    responses: {
      200: {
        description: "Success",
        content: {
          "application/json": { schema: resolver(Entry)}
        }
      },
      404: {
        description: "Entry not found."
      }
    }
  }),
  validator("param", EntryQuery),
  (c) => {
    c.status(404);
    return c.body(null);
  }
);

export default app;
