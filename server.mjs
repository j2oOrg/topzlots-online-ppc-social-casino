import { createServer } from "node:http";
import { createReadStream } from "node:fs";
import { stat } from "node:fs/promises";
import { join, resolve, dirname, extname } from "node:path";
import { fileURLToPath } from "node:url";
import dns from "node:dns/promises";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const distDir = resolve(__dirname, "dist");
const indexFile = join(distDir, "index.html");

const SERVER_PORT = Number(process.env.PORT ?? 8080);
const GOOGLE_AGENT_REGEX = /google/i;
const GOOGLE_HOST_SUFFIXES = [".google.com", ".googlebot.com"];
const AGE_COOKIE_HEADER = "adult=1; Max-Age=31536000; Path=/; SameSite=Lax";
const DNS_CACHE_TTL_MS = 6 * 60 * 60 * 1000; // 6 hours

const MIME_TYPES = {
  ".html": "text/html; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".gif": "image/gif",
  ".webp": "image/webp",
  ".ico": "image/x-icon",
  ".woff": "font/woff",
  ".woff2": "font/woff2",
  ".ttf": "font/ttf",
  ".otf": "font/otf",
  ".txt": "text/plain; charset=utf-8",
  ".xml": "application/xml; charset=utf-8",
  ".map": "application/json; charset=utf-8",
};

const dnsCache = new Map();

const normalizeIp = (ip) => {
  if (!ip) return "";
  return ip.startsWith("::ffff:") ? ip.slice(7) : ip;
};

const getClientIps = (req) => {
  const forwarded = req.headers["x-forwarded-for"];
  if (typeof forwarded === "string" && forwarded.length > 0) {
    return forwarded.split(",").map((part) => normalizeIp(part.trim())).filter(Boolean);
  }
  return [normalizeIp(req.socket.remoteAddress)];
};

const sanitizePath = (pathname) => {
  if (!pathname) return "";
  const decoded = decodeURIComponent(pathname.split("?")[0] ?? "/");
  const segments = decoded.split("/").filter((segment) => segment && segment !== "..");
  return segments.join("/");
};

const safeStat = async (target) => {
  try {
    return await stat(target);
  } catch {
    return null;
  }
};

const cacheDnsResult = (ip, value, ttl = DNS_CACHE_TTL_MS) => {
  dnsCache.set(ip, { value, expiresAt: Date.now() + ttl });
};

const isGoogleIp = async (ip) => {
  if (!ip) return false;

  const cached = dnsCache.get(ip);
  if (cached && cached.expiresAt > Date.now()) {
    return cached.value;
  }

  try {
    const hostnames = await dns.reverse(ip);
    for (const hostname of hostnames) {
      if (!GOOGLE_HOST_SUFFIXES.some((suffix) => hostname.endsWith(suffix))) {
        continue;
      }

      const forwardEntries = await dns.lookup(hostname, { all: true });
      const matchesOriginal = forwardEntries.some(
        (entry) => normalizeIp(entry.address) === ip,
      );

      if (matchesOriginal) {
        cacheDnsResult(ip, true);
        return true;
      }
    }
  } catch {
    // swallow DNS errors and fall through to caching false
  }

  cacheDnsResult(ip, false, 30 * 60 * 1000); // negative cache for 30 minutes
  return false;
};

const shouldFallbackToIndex = (pathname) => {
  if (!pathname) return true;
  const ext = extname(pathname).toLowerCase();
  return ext === "" || ext === ".html";
};

const sendNotFound = (res) => {
  res.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
  res.end("Not Found");
};

const sendError = (res, error) => {
  console.error("Server error:", error);
  res.writeHead(500, { "Content-Type": "text/plain; charset=utf-8" });
  res.end("Internal Server Error");
};

const serveFile = (req, res, filePath, statusCode = 200) => {
  const ext = extname(filePath).toLowerCase();
  const contentType = MIME_TYPES[ext] ?? "application/octet-stream";
  const cacheHeader =
    ext === ".html" || filePath === indexFile
      ? "no-cache"
      : "public, max-age=31536000, immutable";

  res.writeHead(statusCode, {
    "Content-Type": contentType,
    "Cache-Control": cacheHeader,
  });

  if (req.method === "HEAD") {
    res.end();
    return;
  }

  createReadStream(filePath).pipe(res);
};

const server = createServer(async (req, res) => {
  try {
    const requestUrl = new URL(req.url ?? "/", `http://${req.headers.host ?? "localhost"}`);
    const sanitizedPathname = sanitizePath(requestUrl.pathname);
    let candidatePath = sanitizedPathname
      ? join(distDir, sanitizedPathname)
      : indexFile;

    if (!candidatePath.startsWith(distDir)) {
      sendNotFound(res);
      return;
    }

    let stats = await safeStat(candidatePath);

    if (!stats) {
      if (shouldFallbackToIndex(requestUrl.pathname)) {
        candidatePath = indexFile;
        stats = await safeStat(candidatePath);
      } else {
        sendNotFound(res);
        return;
      }
    } else if (stats.isDirectory()) {
      const nestedIndex = join(candidatePath, "index.html");
      if (!nestedIndex.startsWith(distDir)) {
        sendNotFound(res);
        return;
      }

      const nestedStats = await safeStat(nestedIndex);
      if (nestedStats) {
        candidatePath = nestedIndex;
        stats = nestedStats;
      } else if (shouldFallbackToIndex(requestUrl.pathname)) {
        candidatePath = indexFile;
        stats = await safeStat(candidatePath);
      } else {
        sendNotFound(res);
        return;
      }
    }

    const userAgent = req.headers["user-agent"] ?? "";
    let shouldBypass = GOOGLE_AGENT_REGEX.test(userAgent);

    if (!shouldBypass) {
      const ips = getClientIps(req);
      for (const ip of ips) {
        // eslint-disable-next-line no-await-in-loop
        if (await isGoogleIp(ip)) {
          shouldBypass = true;
          break;
        }
      }
    }

    if (shouldBypass) {
      res.setHeader("Set-Cookie", AGE_COOKIE_HEADER);
    }

    serveFile(req, res, candidatePath);
  } catch (error) {
    sendError(res, error);
  }
});

server.listen(SERVER_PORT, () => {
  console.log(`Server listening on port ${SERVER_PORT}`);
});
