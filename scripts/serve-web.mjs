import { createReadStream } from 'node:fs';
import { stat } from 'node:fs/promises';
import { createServer } from 'node:http';
import { extname, resolve, sep } from 'node:path';

const host = process.env.WEB_HOST ?? '127.0.0.1';
const port = Number(process.env.WEB_PORT ?? 8080);
const root = resolve(process.cwd(), 'build', 'web');
const contentTypes = {
  '.css': 'text/css; charset=utf-8',
  '.html': 'text/html; charset=utf-8',
  '.ico': 'image/x-icon',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
  '.wasm': 'application/wasm',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
};

const server = createServer(async (request, response) => {
  try {
    const url = new URL(request.url ?? '/', `http://${request.headers.host}`);
    const requestedPath = decodeURIComponent(url.pathname);
    let filePath = resolve(root, `.${requestedPath}`);
    if (filePath !== root && !filePath.startsWith(`${root}${sep}`)) {
      response.writeHead(403).end('Forbidden');
      return;
    }

    try {
      const file = await stat(filePath);
      if (file.isDirectory()) filePath = resolve(filePath, 'index.html');
    } catch {
      filePath = resolve(root, 'index.html');
    }

    response.writeHead(200, {
      'Content-Type': contentTypes[extname(filePath)] ?? 'application/octet-stream',
      'Cache-Control': 'no-store',
    });
    createReadStream(filePath).pipe(response);
  } catch {
    response.writeHead(500).end('Unable to serve the web application.');
  }
});

server.listen(port, host, () => {
  console.log(`Loan web app available at http://${host}:${port}`);
});
