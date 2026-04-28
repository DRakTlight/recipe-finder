const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

const ALLOWED_HOSTS = new Set(["img.spoonacular.com"]);

exports.spoonacularImageProxy = onRequest(
  {
    region: "us-central1",
    cors: true,
    memory: "256MiB",
    timeoutSeconds: 30,
  },
  async (req, res) => {
    try {
      if (req.method !== "GET" && req.method !== "HEAD") {
        res.status(405).send("Method not allowed");
        return;
      }

      const rawUrl = req.query.url;
      if (!rawUrl || typeof rawUrl !== "string") {
        res.status(400).send("Missing 'url' query param");
        return;
      }

      let parsed;
      try {
        parsed = new URL(rawUrl);
      } catch {
        res.status(400).send("Invalid url");
        return;
      }

      if (parsed.protocol !== "https:" || !ALLOWED_HOSTS.has(parsed.hostname)) {
        res.status(403).send("URL host not allowed");
        return;
      }

      const fetch = (await import("node-fetch")).default;
      const upstream = await fetch(rawUrl, {
        method: req.method,
        redirect: "follow",
        headers: {
          // Basic UA helps some CDNs; harmless otherwise.
          "user-agent": "recipe-finder-image-proxy/1.0",
        },
      });

      if (!upstream.ok) {
        res.status(upstream.status).send("Upstream error");
        return;
      }

      const contentType = upstream.headers.get("content-type") || "application/octet-stream";
      res.setHeader("content-type", contentType);
      res.setHeader("cache-control", "public, max-age=86400, s-maxage=86400");

      if (req.method === "HEAD") {
        res.status(200).end();
        return;
      }

      const buf = Buffer.from(await upstream.arrayBuffer());
      res.status(200).send(buf);
    } catch (e) {
      res.status(500).send("Proxy failed");
    }
  }
);

