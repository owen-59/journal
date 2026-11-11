import path from "node:path";
import config from "../config.js";
import { format } from "date-fns";

export function getPathFromDt(dt: Date) {
  return path.join(config.JOURNAL_DATA, format(dt, "yyyy/MM/dd/HHmm.'md'"));
}
