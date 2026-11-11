import "dotenv/config";
import * as v from "valibot";

const ConfigSchema = v.object({
  JOURNAL_DATA: v.string(),
});

const config = v.parse(ConfigSchema, process.env);

export default config;
