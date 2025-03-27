# Etap pierwszy - budowanie aplikacji
FROM node:alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY index.js .
ARG VERSION=1.0.0
ENV VERSION=${VERSION}

# Etap drugi - serwer Nginx
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

# Instalacja Node.js w obrazie Nginx
RUN apk add --no-cache nodejs npm
WORKDIR /usr/share/nginx/html
RUN npm install express os

# Kopiowanie plików Node.js
COPY --from=build /app/index.js .
COPY --from=build /app/package*.json ./

# Expose port
EXPOSE 3000 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000 || exit 1

# Uruchomienie Node.js i Nginx
CMD sh -c "node index.js & nginx -g 'daemon off;'"