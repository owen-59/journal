import { type Entry } from "../schemas.js";
import { getPathFromDt } from "../utils/path.js";
import matter from "gray-matter";
import fs from "node:fs/promises";
import * as v from "valibot";

const FrontMatterSchema = v.object({
  tags: v.nullish(v.array(v.string()), []),
  images: v.nullish(v.array(v.string()), []),
  location: v.optional(v.strictTuple([v.number(), v.number()])),
  place_name: v.optional(v.string()),
  address: v.optional(v.string()),
});

export async function readEntry(dt: Date): Promise<Entry | null> {
  const entryPath = getPathFromDt(dt);
  try {
    const rawContent = await fs.readFile(entryPath, "utf8");
    const { data: rawData, content } = matter(rawContent);

    const parsedFrontmatter = v.safeParse(FrontMatterSchema, rawData);
    let data: v.InferOutput<typeof FrontMatterSchema>;
    if (!parsedFrontmatter.success) {
      data = v.parse(FrontMatterSchema, {});
    } else {
      data = parsedFrontmatter.output;
    }

    return {
      body: content,
      datetime: dt,
      tags: data.tags,
      images: data.images,
      location: data.location
        ? {
            coordinates: data.location,
            address: data.address,
            placeName: data.place_name,
          }
        : undefined,
    };
  } catch (err) {
    if (err instanceof Error && "code" in err && err.code == "ENOENT") {
      return null;
    }
    console.error(`Unknown error occurred when reading ${entryPath}: ${err}`);
    return null;
  }
}
