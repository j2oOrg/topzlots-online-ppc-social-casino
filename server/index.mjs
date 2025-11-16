import { createServer } from "node:http";
import { createReadStream } from "node:fs";
import { promises as fs } from "node:fs";
import dns from "node:dns/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const distDir = path.resolve(__dirname, "../dist");
const indexFile = path.join(distDir, "index.html");

const MIME_TYPES = {
  ".html": "text/html; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".webp": "image/webp",
  ".avif": "image/avif",
  ".ico": "image/x-icon",
  ".gif": "image/gif",
  ".txt": "text/plain; charset=utf-8",
  ".xml": "application/xml; charset=utf-8",
  ".woff": "font/woff",
  ".woff2": "font/woff2",
};

const AGE_GATE_COOKIE = "age_gate_verified=true; Path=/; Max-Age=31536000; SameSite=Lax";

function getClientIp(req) {
  const forwarded = req.headers["x-forwarded-for"];
  if (typeof forwarded === "string" && forwarded.length > 0) {
    return forwarded.split(",")[0].trim();
  }

  const remote = req.socket?.remoteAddress;
  if (!remote) {
    return undefined;
  }

  return remote.startsWith("::ffff:") ? remote.slice(7) : remote;
}

function hasAgeGateCookie(req) {
  const cookieHeader = req.headers["cookie"];
  if (typeof cookieHeader !== "string") {
    return false;
  }

  return cookieHeader.split(";").some((part) => part.trim().startsWith("age_gate_verified="));
}

async function isVerifiedGooglebot(ip) {
  if (!ip) {
    return false;
  }

  try {
    const hostnames = await dns.reverse(ip);
    const verifiedHostname = hostnames.find(
      (hostname) =>
        hostname.endsWith(".googlebot.com") ||
        hostname.endsWith(".google.com"),
    );

    if (!verifiedHostname) {
      return false;
    }

    const lookupResult = await dns.lookup(verifiedHostname, { all: true });
    return lookupResult.some((record) => record.address === ip);
  } catch (error) {
    return false;
  }
}

function expectsHtml(req) {
  const accept = req.headers["accept"];
  if (typeof accept !== "string") {
    return req.method === "GET" && (!req.url || req.url === "/" || !path.extname(req.url));
  }
  return accept.includes("text/html") || accept.includes("*/*");
}

async function maybeSetAgeGateBypass(req, res) {
  if (req.method !== "GET") {
    return;
  }

  if (!expectsHtml(req) || hasAgeGateCookie(req)) {
    return;
  }

  const clientIp = getClientIp(req);
  if (!clientIp) {
    return;
  }

  const verified = await isVerifiedGooglebot(clientIp);
  if (verified) {
    res.setHeader("Set-Cookie", AGE_GATE_COOKIE);
    res.setHeader("X-Age-Gate-Bypass", "googlebot");
  }
}

async function fileExists(filePath) {
  try {
    const stats = await fs.stat(filePath);
    return stats.isFile();
  } catch (error) {
    return false;
  }
}

function sendFile(res, filePath, statusCode = 200) {
  const ext = path.extname(filePath).toLowerCase();
  const contentType = MIME_TYPES[ext] ?? "application/octet-stream";

  res.writeHead(statusCode, { "Content-Type": contentType });

  if (statusCode === 204) {
    res.end();
    return;
  }

  const stream = createReadStream(filePath);
  stream.on("error", () => {
    res.writeHead(500, { "Content-Type": "text/plain; charset=utf-8" });
    res.end("Internal Server Error");
  });
  stream.pipe(res);
}

const server = createServer(async (req, res) => {
  const method = req.method ?? "GET";

  if (method !== "GET" && method !== "HEAD") {
    res.writeHead(405, { Allow: "GET, HEAD" });
    res.end();
    return;
  }

  const requestUrl = new URL(req.url ?? "/", `http://${req.headers.host ?? "localhost"}`);
  const rawPath = decodeURIComponent(requestUrl.pathname);

  if (rawPath.includes("\0")) {
    res.writeHead(400);
    res.end("Bad Request");
    return;
  }

  const normalizedPath = path
    .normalize(rawPath)
    .replace(/^(\.\.(\/|\\|$))+/, "");

  const trimmedPath = normalizedPath.startsWith("/")
    ? normalizedPath.slice(1)
    : normalizedPath;

  let candidatePath = path.join(distDir, trimmedPath);

  if (!candidatePath.startsWith(distDir)) {
    res.writeHead(403);
    res.end("Forbidden");
    return;
  }

  let targetPath = candidatePath;
  let shouldFallbackToIndex = false;

  if (trimmedPath === "" || trimmedPath === "index.html") {
    targetPath = indexFile;
  } else {
    const hasExtension = path.extname(trimmedPath) !== "";
    const exists = await fileExists(candidatePath);

    if (!exists) {
      if (hasExtension) {
        res.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
        res.end("Not Found");
        return;
      }
      shouldFallbackToIndex = true;
    }
  }

  if (shouldFallbackToIndex) {
    targetPath = indexFile;
  }

  await maybeSetAgeGateBypass(req, res);

  if (method === "HEAD") {
    const ext = path.extname(targetPath).toLowerCase();
    const contentType = MIME_TYPES[ext] ?? "application/octet-stream";
    res.writeHead(200, { "Content-Type": contentType });
    res.end();
    return;
  }

  sendFile(res, targetPath);
});

const port = Number.parseInt(process.env.PORT ?? "8080", 10);
const host = process.env.HOST ?? "0.0.0.0";

server.listen(port, host, () => {
  const timestamp = new Date().toISOString();
  // eslint-disable-next-line no-console
  console.log(`[${timestamp}] Static server listening on http://${host}:${port}`);
});
