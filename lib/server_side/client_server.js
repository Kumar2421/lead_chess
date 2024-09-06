const WebSocket = require('ws');

const serverUrl = 'ws://149.47.240.31:3003'; // Connect to the Node.js proxy server
let ws;

function connect() {
  ws = new WebSocket(serverUrl);

  ws.on('open', function open() {
    console.log('Connected to WebSocket server');
    ws.send('Hello from Node.js WebSocket client');
  });

  ws.on('message', function incoming(data) {
    const message = data.toString('utf8');
    console.log('Received message from WebSocket server:', message);
  });

  ws.on('close', function close() {
    console.log('Disconnected from WebSocket server');
    retryConnection();
  });

  ws.on('error', function error(err) {
    console.error('WebSocket error:', err);
    retryConnection();
  });
}

function retryConnection() {
  console.log('Retrying connection in 5 seconds...');
  setTimeout(connect, 5000);
}

// Initial connection attempt
try {
  connect();
} catch (err) {
  console.error('Failed to establish WebSocket connection:', err);
  retryConnection();
}
