# syntax=docker/dockerfile:1.3-labs
FROM alpine AS downloader
RUN apk add --no-cache git openssh
COPY known_hosts /etc/ssh/ssh_known_hosts
RUN --mount=type=ssh git clone git@github.com:JacKoz7/pawcho6.git /app

# Etap 2 - build Node.js z pobranym kodem
FROM node:20-alpine AS build
WORKDIR /app
COPY --from=downloader /app/package*.json ./
RUN npm install
COPY --from=downloader /app/index.js .
ARG VERSION=1.0.0
ENV VERSION=${VERSION}

# Etap 3 - nginx + frontend
FROM nginx:alpine
COPY --from=build /app /usr/share/nginx/html

COPY <<EOF /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<head><title>Server Info</title></head>
<body>
  <h1>Server Information Loading...</h1>
  <div id="serverInfo"></div>
  <script>
    fetch('/')
      .then(response => response.text())
      .then(html => {
        document.getElementById('serverInfo').innerHTML = html;
      });
  </script>
</body>
</html>
EOF

RUN apk add --no-cache nodejs npm
WORKDIR /usr/share/nginx/html
RUN npm install express os

COPY --from=build /app/index.js .
COPY --from=build /app/package*.json ./

EXPOSE 3000 80

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000 || exit 1

# Startup script for multiple processes
COPY <<EOF /start.sh
#!/bin/sh
node /usr/share/nginx/html/index.js &
nginx -g 'daemon off;'
EOF
RUN chmod +x /start.sh

CMD ["/start.sh"]