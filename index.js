const express = require('express');
const os = require('os');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  const networkInterfaces = os.networkInterfaces();
  const ipAddress = Object.values(networkInterfaces)
    .flat()
    .filter(details => details.family === 'IPv4' && !details.internal)[0]?.address || 'N/A';

  const hostname = os.hostname();
  const version = process.env.VERSION || '1.0.0';

  res.send(`
    <html>
      <body>
        <h1>Server Information</h1>
        <p>IP Address: ${ipAddress}</p>
        <p>Hostname: ${hostname}</p>
        <p>Application Version: ${version}</p>
      </body>
    </html>
  `);
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});