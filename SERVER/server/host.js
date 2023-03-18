const os = require("os");

// Hostname and port configuration --------------------------------

const nets = os.networkInterfaces();
const results = Object.create(null); // Or just '{}', an empty object

for (const name of Object.keys(nets)) {
    for (const net of nets[name]) {
        // Skip over non-IPv4 and internal (i.e. 127.0.0.1) addresses
        // 'IPv4' is in Node <= 17, from 18 it's a number 4 or 6
        const familyV4Value = typeof net.family === 'string' ? 'IPv4' : 4
        if (net.family === familyV4Value && !net.internal) {
            if (!results[name]) {
                results[name] = [];
            }
            results[name].push(net.address);
        }
    }
}


const port = 3000; 
const hostname = (results["en0"] ?? results["en1"] ?? results[Object.keys(results)[0]])[0];

// ----------------------------------------------------------------

module.exports = {
    port: port,
    hostname: hostname,
}


