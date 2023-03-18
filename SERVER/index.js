const host = require('./server/host.js');
const app = require('./server/app.js');
const http = require('http');

// const server = https.createServer(cert.cert, app.app);

const server = http.createServer(app.app);

// Tạo server lắng nghe
server.listen(host.port, () => {
    console.log(`Server running at http://${host.hostname}:${host.port}`)
});