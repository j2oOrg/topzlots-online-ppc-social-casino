import http from "node:http";
import { promises as fs } from "node:fs";
import { createReadStream } from "node:fs";
import path from "node:path";
import url from "node:url";

const DIST_DIR = path.resolve("dist");
const INDEX_FILE = path.join(DIST_DIR, "index.html");

const MIME_TYPES = {
  ".html": "text/html; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".gif": "image/gif",
  ".svg": "image/svg+xml",
  ".webp": "image/webp",
  ".ico": "image/x-icon",
  ".txt": "text/plain; charset=utf-8",
  ".xml": "application/xml; charset=utf-8",
  ".woff": "font/woff",
  ".woff2": "font/woff2",
  ".ttf": "font/ttf",
  ".otf": "font/otf",
};

const GOOGLE_AGENT_REGEX = /google/i;
const GOOGLE_DNS_IPS = new Set([
  "8.8.8.8",
  "8.8.4.4",
  "8.34.34.34",
  "8.35.35.35",
  "2001:4860:4860::8888",
  "2001:4860:4860::8844",
]);

const AGE_COOKIE = "age-verified=true; Max-Age=31536000; Path=/; SameSite=Lax";

const normalizeIp = (rawAddress = "") => {
  let address = rawAddress.trim();

  if (!address) {
    return "";
  }

  // Handle IPv6 formats like ::ffff:127.0.0.1
  if (address.startsWith("::ffff:")) {
    address = address.slice(7);
  }

  // Remove surrounding brackets for IPv6 addresses.
  if (address.startsWith("[") && address.endsWith("]")) {
    address = address.slice(1, -1);
  }

  return address;
};

const isGoogleRequest = (req) => {
  const userAgent = req.headers["user-agent"] ?? "";
  if (GOOGLE_AGENT_REGEX.test(userAgent)) {
    return true;
  }

  const forwardedFor = req.headers["x-forwarded-for"] ?? "";
  const candidateAddresses = [
    ...forwardedFor
      .split(",")
      .map((entry) => normalizeIp(entry))
      .filter(Boolean),
    normalizeIp(req.socket.remoteAddress),
  ];

  return candidateAddresses.some((address) =>
    GOOGLE_DNS_IPS.has(address.toLowerCase())
  );
};

const fileExists = async (filePath) => {
  try {
    const stats = await fs.stat(filePath);
    return stats.isFile();
  } catch {
    return false;
  }
};

const resolveFilePath = async (requestedPath) => {
  // Prevent directory traversal
  const safePath = path
    .normalize(requestedPath)
    .replace(/^(\.\.(\/|\\|$))+/, "");
  let filePath = path.join(DIST_DIR, safePath);

  if (await fileExists(filePath)) {
    return filePath;
  }

  // Attempt to serve index.html for directories and SPA routes
  const directoryIndex = path.join(filePath, "index.html");
  if (await fileExists(directoryIndex)) {
    return directoryIndex;
  }

  return INDEX_FILE;
};

const server = http.createServer(async (req, res) => {
  try {
    if (!req.url) {
      res.writeHead(400).end("Bad Request");
      return;
    }

    // Set the age verification cookie for Google-origin traffic
    if (isGoogleRequest(req)) {
      res.setHeader("Set-Cookie", AGE_COOKIE);
    }

    const parsedUrl = url.parse(req.url);
    const pathname = parsedUrl.pathname ?? "/";
    const filePath = await resolveFilePath(pathname);
    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] ?? "application/octet-stream";

    const stream = createReadStream(filePath);
    stream.on("open", () => {
      res.writeHead(200, { "Content-Type": contentType });
      stream.pipe(res);
    });

    stream.on("error", () => {
      res.writeHead(500).end("Internal Server Error");
    });
  } catch (error) {
    res.writeHead(500).end("Internal Server Error");
  }
});

const PORT = Number.parseInt(process.env.PORT ?? "8080", 10);

server.listen(PORT, "0.0.0.0", () => {
  console.log(`Server listening on port ${PORT}`);
});
