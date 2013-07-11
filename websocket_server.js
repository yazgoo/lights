net = require('net');
var WebSocketServer = require('/usr/lib/node_modules/ws').Server
var wss = new WebSocketServer({port: 8080});
wss.on('connection', function(conn) {
    var client = net.connect({port: 1883}, function() { });
    client.on('data', function(data) { console.log(data);conn.send(data); });
    client.on('end', function() { conn.close(); });
    client.on('error', function(err){ console.log(err); });
    conn.on('message', function(mess) { client.write(mess); });
    conn.on('close', function() { client.end(); });
    conn.on('error', function(err){ console.log(err); });
});
