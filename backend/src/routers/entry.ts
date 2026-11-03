import { Hono } from "hono";
import { describeRoute, resolver, validator } from "hono-openapi";
import { EntryQuery, EntrySchema } from "../schemas.js";
import { readEntry } from "../repository/entry.js";

type Env = {
  Variables: {
    dt: Date;
  };
};

const app = new Hono<Env>();

app.get(
  "/:year/:month/:day/:hour/:minute",
  describeRoute({
    description: "Get entry at some datetime",
    responses: {
      200: {
        description: "Success",
        content: {
          "application/json": { schema: resolver(EntrySchema) },
        },
      },
      404: {
        description: "Entry not found.",
      },
    },
  }),
  validator("param", EntryQuery),
  async (c, next) => {
    c.set(
      "dt",
      new Date(
        c.req.valid("param").year,
        c.req.valid("param").month - 1,
        c.req.valid("param").day,
        c.req.valid("param").hour,
        c.req.valid("param").minute,
      ),
    );
    await next();
  },
  async (c) => {
    const entry = await readEntry(c.get("dt"));
    if (entry) {
      return c.json(entry, 200);
    }
    return c.body(null, 404);
  },
);

export default app;
