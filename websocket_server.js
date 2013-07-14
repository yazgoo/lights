#!/usr/bin/env nodejs
net = require('net');
var WebSocketServer = require('/usr/local/lib/node_modules/ws').Server
var wss = new WebSocketServer({port: 8080});
wss.on('connection', function(conn) {
    var client = net.connect({host: 'localhost', port: 1883}, function() { console.log("connect"); });
    client.on('data', function(data) {
        console.log("data: " + data);
        conn.send(data);
    });
    client.on('end', function() { conn.close(); });
    client.on('error', function(err){ console.log(err); });
    conn.on('message', function(mess) { client.write(mess); });
    conn.on('close', function() { client.end(); });
    conn.on('error', function(err){ console.log(err); });
});
