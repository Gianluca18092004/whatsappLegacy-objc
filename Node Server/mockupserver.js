const express = require('express')
const axios = require('axios')
const path = require('path');
const fs = require('fs');

const app = express()

// Keep track of the chat clients
var clients = [], queueClients = [], presences = {};

function reconnect(socket) {
  console.log(`Attempting to reconnect with ${socket.name}`);
  
  setTimeout(() => {
    // Volver a añadir el socket a la lista de clientes en cola si aún no está
    if (queueClients.indexOf(socket) === -1 && clients.indexOf(socket) === -1) {
      socket.connect(7300, "192.168.100.32", () => {
        console.log(`${socket.name} reconnected`);
        queueClients.push(socket);
      });
    }
  }, 5000); // Intentar reconectar tras 5 segundos
}

net.createServer(function (socket) {
    socket.name = socket.remoteAddress + ":" + socket.remotePort;
  
    queueClients.push(socket);
  
    console.log(socket.name + " is connected\n");
    socket.write(JSON.stringify({
      "sender": "wspl-server",
      "token": "3qGT_%78Dtr|&*7ufZoO"
    }));
  
    socket.on('data', function (data) {
      if(clients.indexOf(socket) === -1) {
        const jsonContent = JSON.parse(data);
        if(jsonContent.sender === "wspl-client" && jsonContent.token === "vC.I)Xsfe(;p4YB6E5@y") {
          queueClients.splice(queueClients.indexOf(socket), 1);
          clients.push(socket);
          socket.write(JSON.stringify({
            "sender": "wspl-server",
            "response": "ok"
          }));
        } else {
          socket.write(JSON.stringify({
            "sender": "wspl-server",
            "response": "reject"
          }));
          socket.destroy();
          queueClients.splice(queueClients.indexOf(socket), 1);
        }
      }
    });
  
    socket.on('end', function () {
      queueClients.splice(queueClients.indexOf(socket), 1);
      clients.splice(clients.indexOf(socket), 1);
      console.log(socket.name + " left connection.\n");
    });
  
    // Manejar errores y reconectar
    socket.on('error', function (err) {
      console.error(`Error with ${socket.name}:`, err.code);
      reconnect(socket);
    });
  
  }).listen(7300, "192.168.100.32");

  app.get('/', async (req, res) => {
    res.send("WhatsApp Legacy mockup server")
  })