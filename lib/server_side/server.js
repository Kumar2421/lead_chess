const http = require('http');
const WebSocket = require('ws');

const proxyServer = http.createServer();
const wss = new WebSocket.Server({ noServer: true });

const clients = new Map();

proxyServer.on('upgrade', (request, socket, head) => {
  wss.handleUpgrade(request, socket, head, (ws) => {
    wss.emit('connection', ws, request);
  });
});

wss.on('connection', (clientWs, request) => {
  console.log('New WebSocket connection from client.');

  const dartServerWs = new WebSocket('ws://192.168.1.14:3002'); // Dart server URL

  clients.set(clientWs, dartServerWs);
  clients.set(dartServerWs, clientWs);

  dartServerWs.on('open', () => {
    console.log('Connected to Dart WebSocket server.');

    clientWs.on('message', (message) => {
      if (dartServerWs.readyState === WebSocket.OPEN) {
        dartServerWs.send(message);
      } else {
        console.error('Dart server WebSocket is not open. Message not sent.');
      }
    });
  });

  dartServerWs.on('message', (data) => {
    console.log('Received message from Dart server:', data.toString());
    clientWs.send(data.toString()); // Forward message to the client as string
  });

  clientWs.on('close', () => {
    console.log('Client WebSocket connection closed.');
    cleanup(clientWs);
  });

  dartServerWs.on('close', () => {
    console.log('Dart server WebSocket connection closed.');
    cleanup(dartServerWs);
  });

  function cleanup(ws) {
    const otherWs = clients.get(ws);
    if (otherWs) {
      clients.delete(ws);
      clients.delete(otherWs);
      otherWs.close();
    }
  }
});

proxyServer.listen(3003, () => {
  console.log('Node.js proxy server running on port 3005');
});
