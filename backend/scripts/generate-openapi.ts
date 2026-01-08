import { writeFileSync } from "fs";
import app from "../src/server";

// We mock the Env and other bindings since we only need the router definition
const doc = app.getOpenAPI31Document({
  openapi: "3.1.0",
  info: {
    version: "1.0.0",
    title: "TriTalk API",
  },
});

writeFileSync("swagger.json", JSON.stringify(doc, null, 2));
console.log("✅ swagger.json generated successfully.");
