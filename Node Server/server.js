const express = require('express')
const axios = require('axios')
const { Client, RemoteAuth, MessageMedia, Wha, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const net = require('net');
const crypto = require('crypto');
const ffmpeg = require('fluent-ffmpeg');
const ffmpegStatic = require('ffmpeg-static');
const path = require('path');
const fs = require('fs');

const app = express()
app.use(express.json({ limit: '16mb' }));
app.use(express.urlencoded({ limit: '16mb', extended: true }));
ffmpeg.setFfmpegPath(ffmpegStatic);

const client = new Client({
  puppeteer: {
    headless: true,
    args: [
      "--no-sandbox",
    "--disable-setuid-sandbox",
    "--log-level=3",
    "--no-default-browser-check",
    "--disable-site-isolation-trials",
    "--no-experiments",
    "--ignore-gpu-blacklist",
    "--ignore-certificate-errors",
    "--ignore-certificate-errors-spki-list",
    "--enable-gpu",
    // "--disable-extensions",
    "--disable-default-apps",
    "--enable-features=NetworkService",
    "--disable-webgl",
    "--disable-threaded-animation",
    "--disable-threaded-scrolling",
    "--disable-in-process-stack-traces",
    "--disable-histogram-customizer",
    "--disable-gl-extensions",
    "--disable-composited-antialiasing",
    "--disable-canvas-aa",
    "--disable-3d-apis",
    "--disable-accelerated-2d-canvas",
    "--disable-accelerated-jpeg-decoding",
    "--disable-accelerated-mjpeg-decode",
    "--disable-app-list-dismiss-on-blur",
    "--disable-accelerated-video-decode",
      "--window-position=-200,-200",
      "--window-size=1,1"
    ],
    executablePath: 'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe'
  },
  authStrategy: new LocalAuth()
});

  
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

  client.setMaxListeners(16);

  client.on('message_create', async (msg) => {
    socket.write(JSON.stringify({
      "sender": "wspl-server",
      "response": "NEW_MESSAGE"
    }));
  });

  client.on('message', async (msg) => {
    if(msg.broadcast == true){
      socket.write(JSON.stringify({
        "sender": "wspl-server",
        "response": "NEW_BROADCAST_NOTI"
      }));
    } else {
      socket.write(JSON.stringify({
        "sender": "wspl-server",
        "response": "NEW_MESSAGE_NOTI",
        "body": {
          "msgBody": msg.body,
          "from": msg.from.split('@')[0],
          "author": (!!msg.author ? msg.author.split('@')[0] : ""),
          "type": msg.type
        }
      }));
    }
  });

  client.on('message_ack', async (msg, ack) => {
    socket.write(JSON.stringify({
      "sender": "wspl-server",
      "response": "ACK_MESSAGE",
      "body": {
        "from": msg.from.split('@')[0],
        "msgId": msg.id,
        "ack": ack
      }
    }));
  });

  client.on('message_revoke_me', async (msg) => {
    socket.write(JSON.stringify({
      "sender": "wspl-server",
      "response": "REVOKE_MESSAGE"
    }));
  });

  client.on('message_revoke_everyone', async (msg, rmsg) => {
    socket.write(JSON.stringify({
      "sender": "wspl-server",
      "response": "REVOKE_MESSAGE"
    }));
  });

  client.on('group_join', async (msg) => {
    socket.write(JSON.stringify({
      "sender": "wspl-server",
      "response": "NEW_MESSAGE"
    }));
  });

  client.on('group_update', async (msg) => {
    socket.write(JSON.stringify({
      "sender": "wspl-server",
      "response": "NEW_MESSAGE"
    }));
  });

  /*client.on('contact_change_state', async (state, id) => {
    socket.write(JSON.stringify({
      "sender": "wspl-server",
      "response": "CONTACT_CHANGE_STATE",
      "body": {
        "status": state,
        "from": id.split('@')[0]
      }
    }));
  })*/

  client.on('chat_state_changed', ({ chatId, chatState}) => {
    socket.write(JSON.stringify({
      "sender": "wspl-server",
      "response": "CONTACT_CHANGE_STATE",
      "body": {
        "status": chatState,
        "from": chatId.split('@')[0]
      }
    }));
  });

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

  function broadcast(message, sender) {
    clients.forEach(function (client) {
      if (client === sender) return;
      client.write(message);
    });
    process.stdout.write(message);
  }

}).listen(7300, "192.168.100.32");

client.on('qr', (qr) => {
    qrcode.generate(qr, {small: true});
});

client.on('ready', () => {
    console.log('Client is ready!');
});

client.on('disconnected', (reason) => {
  //Just to reinitialize on the first page refresh
  console.log("Disconnected")
  if(reInitializeCount === 1 && reason === 'NAVIGATION') {
      reInitializeCount++;
      client.initialize();
      return;
  }
  //Your code for others' reasons for disconnections
});

client.on('remote_session_saved', () => {
  console.log("Sesion guardada")
});

app.get('/', async (req, res) => {
  res.send("WhatsApp Legacy for iOS 3.1 - 6.1.6")
})

app.all('/getChats', async (req, res) => {
  try {
    // Obtener todos los chats
    let _chats = await client.getChats(), chats = [];

    // Filtrar los chats que no tengan timestamp o lastMessage
    let filteredChats = _chats.filter(chat => chat.timestamp || chat.lastMessage);

    const fixChatMsg = async (chat) => {
      let message = chat["lastMessage"];

      if(!!message["_data"]["caption"]){
        message["_data"]["body"] = undefined;
        message["body"] = message["_data"]["caption"];
        message["_data"]["caption"] = undefined;
      }

      chat["lastMessage"] = message;
      return chat;
    }

    chats = await Promise.all(filteredChats.map(fixChatMsg))
    
    // Filtrar los grupos
    let groups = chats.filter(chat => chat.isGroup);
    
    // Crear una lista de promesas para obtener información detallada de cada grupo
    let groupInfoPromises = groups.map(async (group) => {
      let groupInfo = await client.getChatById(group.id._serialized);

      // Añadir la descripción del grupo
      groupInfo["groupDesc"] = groupInfo.description;

      return groupInfo;
    });

    // Esperar a que todas las promesas se resuelvan
    let groupInfos = await Promise.all(groupInfoPromises);

    // Enviar la lista de chats y grupos filtrados como respuesta
    res.json({
      "chatList": chats,
      "groupList": groupInfos
    });
  } catch (err) {
    res.status(500).send('Failed to get chats: ' + err.message);
  }
});

app.post('/syncChat/:contactId', async (req, res) => {
  try {
    let contactId = req.params.contactId + (req.query.isGroup == 1 ? "@g.us" : "@c.us");
    const chat = await client.getChatById(contactId);
    chat.syncHistory();
    res.json({});
  } catch (ex) {
    res.status(500).send(ex.message);
  }
});

app.all('/getBroadcasts', async (req, res) => {
  try {
    // Obtener todos los chats
    let broadcasts = await client.getBroadcasts();

    broadcasts.filter(broadcast => (broadcast.msgs.length > 0))

    // Enviar la lista de broadcast filtrados como respuesta
    res.json({
      "broadcastList": broadcasts
    });
  } catch (err) {
    res.status(500).send('Failed to get chats: ' + err.message);
  }
});

app.all('/getContacts', async (req, res) => {
  let _contacts = await client.getContacts();
  let contacts = [];

  // Filtra los contactos deseados
  const filteredContacts = _contacts.filter(contact => 
      contact.id.server == "c.us" && contact.isWAContact
  );

  // Función para obtener el 'about' de un contacto
  const getContactAbout = async (contact) => {
    if(contact.isMyContact == true && contact.isWAContact == true){
      const profileAbout = await contact.getAbout();
      const profileGroups = await contact.getCommonGroups();
      contact["profileAbout"] = profileAbout;
      contact["commonGroups"] = profileGroups;
    }
    const profileNumber = await contact.getFormattedNumber();
    contact["formattedNumber"] = profileNumber;
    return contact;
  };

  // Ejecuta todas las promesas para obtener el 'about'
  contacts = await Promise.all(filteredContacts.map(getContactAbout));

  // Ordena los contactos por la propiedad 'name'
  contacts.sort((a, b) => {
      // Asegúrate de manejar posibles valores null o undefined
      const nameA = (a.name || "").toLowerCase();
      const nameB = (b.name || "").toLowerCase();
      if (nameA < nameB) return -1;
      if (nameA > nameB) return 1;
      return 0;
  });

  res.json({
    "contactList": contacts
  });
})

app.all('/getGroups', async (req, res) => {
  try {
    // Obtener todos los chats
    let chats = await client.getChats();
    
    // Filtrar los grupos
    let groups = chats.filter(chat => chat.isGroup);
    
    // Crear una lista de promesas para obtener información detallada de cada grupo
    let groupInfoPromises = groups.map(async (group) => {
      let groupInfo = await client.getChatById(group.id._serialized);

      // Añadir la descripción del grupo
      groupInfo["groupDesc"] = groupInfo.description;

      return groupInfo;
    });

    // Esperar a que todas las promesas se resuelvan
    let groupInfos = await Promise.all(groupInfoPromises);
    
    // Enviar la respuesta JSON con la información de los grupos
    res.json({
      "groupList": groupInfos
    });
  } catch (ex) {
    res.status(500).send('Failed to get groups: ' + ex.message);
  }
});

app.all('/getProfileImg/:id', async (req, res) => {
  try {
    let imageUrl = await client.getProfilePicUrl(req.params.id + "@c.us");
    const response = await axios.get(imageUrl, { responseType: 'arraybuffer' });
    const buffer = Buffer.from(response.data, 'binary');

    res.set('Content-Type', response.headers['content-type']);
    res.send(buffer);
  } catch (ex) {
    res.status(500).send(ex.message)
  }
})

app.all('/getGroupImg/:id', async (req, res) => {
  try {
    let imageUrl = await client.getProfilePicUrl(req.params.id + "@g.us");
    const response = await axios.get(imageUrl, { responseType: 'arraybuffer' });
    const buffer = Buffer.from(response.data, 'binary');

    res.set('Content-Type', response.headers['content-type']);
    res.send(buffer);
  } catch (ex) {
    res.status(500).send(ex.message)
  }
})

app.all('/getProfileImgHash/:id', async (req, res) => {
  try {
    let imageUrl = await client.getProfilePicUrl(req.params.id + "@c.us");
    const response = await axios.get(imageUrl, { responseType: 'arraybuffer' });
    const buffer = Buffer.from(response.data, 'binary');

    // Calcular el hash MD5
    const hash = crypto.createHash('md5').update(buffer).digest('hex');

    // Devolver el hash en lugar de la imagen
    res.send(hash);
  } catch (ex) {
    res.send(null);
  }
});

app.all('/getGroupImgHash/:id', async (req, res) => {
  try {
    let imageUrl = await client.getProfilePicUrl(req.params.id + "@g.us");
    const response = await axios.get(imageUrl, { responseType: 'arraybuffer' });
    const buffer = Buffer.from(response.data, 'binary');

    // Calcular el hash MD5
    const hash = crypto.createHash('md5').update(buffer).digest('hex');

    // Devolver el hash en lugar de la imagen
    res.send(hash);
  } catch (ex) {
    res.send(null);
  }
});

app.all('/getGroupInfo/:id', async (req, res) => {
  try {
    let group = await client.getChatById(req.params.id + "@g.us");
    group["groupDesc"] = group.description;

    // Enviar la respuesta una vez que todas las promesas se hayan resuelto
    res.json(group);
  } catch (ex) {
    res.status(500).send(ex.message);
  }
});

app.all('/getChatMessages/:contactId', async (req, res) => {
  try {
    // Obtener el ID del contacto desde los parámetros de la URL
    let contactId = req.params.contactId + (req.query.isGroup == 1 ? "@g.us" : "@c.us");
    
    // Obtener el chat utilizando el ID del contacto
    let chat = await client.getChatById(contactId);
    
    // Cargar mensajes del chat, puedes especificar un límite opcional
    let _messages = await chat.fetchMessages({ limit: (req.query.isLight == 1 ? 100 : 4294967295) }), messages = [];

    const filteredMessages = _messages.filter(message => 
      message["type"] != "notification_template"
    );

    const getMessageReactions = async (message) => {
      /*const quotedMessage = await message.getQuotedMessage();
      if(!!quotedMessage){
        message["quotedMessage"] = quotedMessage;
      }*/
      if(!!message["_data"]["caption"]){
        message["_data"]["body"] = undefined;
        message["body"] = message["_data"]["caption"];
        message["_data"]["caption"] = undefined;
      }
      return message;
    };
    
    messages = await Promise.all(filteredMessages.map(getMessageReactions));

    // Enviar los mensajes como respuesta JSON
    res.setHeader('Content-Type', 'application/json');
    res.json({
      "chatMessages": messages,
      "fromNumber": contactId.split('@')[0]
    });
  } catch (ex) {
    res.status(500).send(ex.message);
  }
});

app.post('/setTypingStatus/:contactId', async (req, res) => {
  try {
    let contactId = req.params.contactId + (req.query.isGroup == 1 ? "@g.us" : "@c.us");
    
    let chat = await client.getChatById(contactId);
    await (req.query.isVoiceNote == 1 ? chat.sendStateRecording() : chat.sendStateTyping());
    res.json({});
  } catch (ex) {
    res.status(500).send(ex.message);
  }
});

app.post('/clearState/:contactId', async (req, res) => {
  try {
    let contactId = req.params.contactId + (req.query.isGroup == 1 ? "@g.us" : "@c.us");
    
    let chat = await client.getChatById(contactId);
    await chat.clearState();
    res.json({});
  } catch (ex) {
    res.status(500).send(ex.message);
  }
});

app.post('/seenBroadcast/:messageId', async (req, res) => {
  try {
    const message = await client.getMessageById(req.params.messageId);
  } catch (ex) {
    res.status(500).send(ex.message);
  }
});

app.all('/getAudioData/:audioId', async (req, res) => {
  try {
    const messageMedia = await client.getMessageById(req.params.audioId);
    const originalMedia = await messageMedia.downloadMedia();

    if (originalMedia) {
      // Guardar el archivo OGG temporalmente
      const oggBuffer = Buffer.from(originalMedia.data, 'base64');
      const tempOggPath = path.join(__dirname, 'temp_audio.ogg');
      fs.writeFileSync(tempOggPath, oggBuffer); // Guardamos el archivo temporalmente como OGG

      // Ruta temporal para el archivo MP3
      const outputPath = path.join(__dirname, 'converted_audio.mp3');

      // Usar FFmpeg para convertir el archivo a MP3
      ffmpeg(tempOggPath)
        .toFormat('mp3')
        .on('end', () => {
          // Una vez que la conversión haya terminado, enviar el archivo convertido
          res.set('Content-Type', 'audio/mpeg');
          res.sendFile(outputPath, (err) => {
            if (err) {
              console.error('Error al enviar el archivo:', err);
              res.status(500).send('Error al enviar el archivo convertido.');
            } else {
              // Eliminar los archivos temporales después de enviarlos
              fs.unlinkSync(tempOggPath);
              fs.unlinkSync(outputPath);
            }
          });
        })
        .on('error', (err) => {
          console.error('Error en la conversión:', err);
          res.status(500).send('Error en la conversión del archivo.');
        })
        .save(outputPath); // Guardamos el archivo convertido
    } else {
      res.status(404).send("Audio not found");
    }
  } catch (ex) {
    if (!res.headersSent) {
      res.status(500).send(ex.message);
    }
  }
});

app.all('/getMediaData/:mediaId', async (req, res) => {
  try {
    const messageMedia = await client.getMessageById(req.params.mediaId);
    const originalMedia = await messageMedia.downloadMedia()

    if(!!originalMedia){
      /*if (originalMedia.mimetype === 'image/webp') {
        const webpBuffer = Buffer.from(originalMedia.data, 'base64');
        const webpFilePath = path.join(__dirname + '\\tmp', `sticker_${Date.now()}.webp`);
        const pngFilePath = path.join(__dirname + '\\tmp', `sticker_${Date.now()}.png`);

        // Guardamos el archivo WebP temporalmente
        fs.writeFileSync(webpFilePath, webpBuffer);

        // Convertimos WebP a PNG
        await webp.dwebp(webpFilePath, pngFilePath, "-o",logging="-v");
        const pngBuffer = fs.readFileSync(pngFilePath);
        fs.unlinkSync(webpFilePath);
        fs.unlinkSync(pngFilePath);
        res.set('Content-Type', 'image/png');
        res.send(pngBuffer);
      } else {*/
        res.set('Content-Type', originalMedia.mimetype);
        res.send(Buffer.from(originalMedia.data, 'base64'));
      //}
    }

    res.status(404).send("Media not found");
  } catch (ex) {
    if (!res.headersSent) { // Asegurarse de que no se hayan enviado los encabezados
      res.status(500).send(ex.message);
    }
  }
});

app.all('/getVideoThumbnail/:mediaId', async (req, res) => {
  try {
    // Obtener el mensaje de video por ID
    const message = await client.getMessageById(req.params.mediaId);

    if (message && message.type === 'video') {
      // Descargar el video
      const originalMedia = await message.downloadMedia();

      if (originalMedia && originalMedia.mimetype.startsWith('video/')) {
        // Convertir el video a un buffer binario
        const videoBuffer = Buffer.from(originalMedia.data, 'base64');
        const videoFilePath = path.join(__dirname, `tmp_${Date.now()}.mp4`);
        const thumbnailFile = `thumbnail_${Date.now()}.png`;
        const thumbnailPath = path.join(__dirname, thumbnailFile);

        // Escribir el video a un archivo temporal
        fs.writeFileSync(videoFilePath, videoBuffer);

        // Usar FFmpeg para extraer el primer fotograma como imagen PNG
        ffmpeg(videoFilePath)
        .on('end', function(files) {
          res.set('Content-Type', 'image/png');
          res.sendFile(thumbnailPath, (err) => {
            if (err) {
              console.error('Error al enviar el archivo:', err);
              res.status(500).send('Error al enviar el archivo convertido.');
            } else {
              // Eliminar los archivos temporales después de enviarlos
              fs.unlinkSync(videoFilePath);
              fs.unlinkSync(thumbnailPath);
            }
          });
        })
        .on('error', function(err) {
          console.error('Error en la conversión:', err);
          res.status(500).send('Error en la conversión del archivo.');
        })
        .screenshots({
          timestamps: [0],
          filename: thumbnailFile,
          folder: __dirname
        });
      } else {
        res.status(404).send('Video not found.');
      }
    } else {
      res.status(404).send('Message not found or it is not a video.');
    }
  } catch (ex) {
    if (!res.headersSent) {
      res.status(500).send(ex.message);
    }
  }
});

app.post('/sendMessage/:contactId', async (req, res) => {
  try {
    // Obtener el ID del contacto desde los parámetros de la URL
    let contactId = req.params.contactId + (req.query.isGroup == 1 ? "@g.us" : "@c.us");
    
    // Obtener el chat utilizando el ID del contacto
    let chat = await client.getChatById(contactId);

    if(!!req.body["messageText"]){
      if(!!req.body["replyTo"]){
        let msgId = req.body["replyTo"],
              msg = client.getMessageById(msgId);
        (await msg).reply(req.body["messageText"]);
      } else {
        chat.sendMessage(req.body["messageText"]);
      }
    }
    if(!!req.body["sendAsVoiceNote"]){
      const base64String = req.body["mediaBase64"]
      // Decodificar el string Base64
      const buffer = Buffer.from(base64String, 'base64');

      // Nombre temporal del archivo CAF
      const tempCafPath = path.join(__dirname, 'temp_audio.caf');
      const outMp3Path = path.join(__dirname, 'test_out.mp3');

      // Guardar el archivo CAF temporalmente
      fs.writeFileSync(tempCafPath, buffer);

      ffmpeg(tempCafPath)
      .toFormat('mp3')
      .on('end', async () => {
        // Eliminar el archivo temporal CAF
        fs.unlinkSync(tempCafPath);

        // Send voicenote
        const audio = await MessageMedia.fromFilePath(outMp3Path);
        await chat.sendMessage(audio, {sendAudioAsVoice: true});
        fs.unlinkSync(outMp3Path);
      })
      .on('error', (err) => {
        console.error('Error durante la conversión:', err);
      })
      .save(outMp3Path);
    }
    if(!!req.body["sendAsPhoto"]){
      const base64String = req.body["mediaBase64"]; // Video en formato base64
      const buffer = Buffer.from(base64String, 'base64');
      const tempJpegPath = path.join(__dirname, 'temp_img.jpg');
      fs.writeFileSync(tempJpegPath, buffer);
      const image = await MessageMedia.fromFilePath(tempJpegPath);
      await chat.sendMessage(image);
      fs.unlinkSync(tempJpegPath);
    }
    res.status(200).json({
      "response": "ok"
    });
  } catch (ex) {
    if (!res.headersSent) { // Asegurarse de que no se hayan enviado los encabezados
      res.status(500).send(ex.message);
    }
  }
});

app.post('/setMute/:contactId/:muteLevel', async (req, res) => {
  try {
    // Obtener el ID del contacto desde los parámetros de la URL
    let contactId = req.params.contactId + (req.query.isGroup == 1 ? "@g.us" : "@c.us");
    
    // Obtener el chat utilizando el ID del contacto
    let chat = await client.getChatById(contactId);
    console.log(req.params.muteLevel);
    switch (parseInt(req.params.muteLevel)) {
      case -1:
        await chat.unmute();
        break;
      case 0:
        await chat.mute(8);
        break;
      case 1:
        await chat.mute(604800000);
        break;
      case 2:
        await chat.mute();
        break;
      default:
        break;
    }
    res.status(200).json({
      "response": "ok"
    });
  } catch (ex) {
    if (!res.headersSent) {
      res.status(500).send(ex.message);
    }
  }
})

app.post('/setBlock/:contactId', async (req, res) => {
  try {
    // Obtener el ID del contacto desde los parámetros de la URL
    let contactId = req.params.contactId + (req.query.isGroup == 1 ? "@g.us" : "@c.us");
    
    // Obtener el contacto utilizando el ID del contacto
    let contact = await client.getContactById(contactId);
    (contact.isBlocked ? await contact.unblock() : await contact.block())
    res.status(200).json({
      "response": "ok"
    });
  } catch (ex) {
    if (!res.headersSent) {
      res.status(500).send(ex.message);
    }
  }
})

app.post('/deleteChat/:contactId', async (req, res) => {
  try {
    // Obtener el ID del contacto desde los parámetros de la URL
    let contactId = req.params.contactId + (req.query.isGroup == 1 ? "@g.us" : "@c.us");
    
    // Obtener el contacto utilizando el ID del contacto
    let chat = await client.getChatById(contactId);
    chat.delete();
    res.status(200).json({
      "response": "ok"
    });
  } catch (ex) {
    if (!res.headersSent) {
      res.status(500).send(ex.message);
    }
  }
})

app.post('/readChat/:contactId', async (req, res) => {
  try {
    // Obtener el ID del contacto desde los parámetros de la URL
    let contactId = req.params.contactId + (req.query.isGroup == 1 ? "@g.us" : "@c.us");
    
    // Obtener el contacto utilizando el ID del contacto
    let chat = await client.getChatById(contactId);
    await chat.sendSeen();
    await client.resetState();
    res.status(200).json({
      "response": "ok"
    });
  } catch (ex) {
    if (!res.headersSent) {
      res.status(500).send(ex.message);
    }
  }
})

app.post('/leaveGroup/:groupId', async (req, res) => {
  try {
    let groupId = req.params.groupId + "@g.us";
    let chat = await client.getChatById(groupId);
    await chat.leave();
    res.status(200).json({
      "response": "ok"
    });
  } catch (ex) {
    if (!res.headersSent) {
      res.status(500).send(ex.message);
    }
  }
})

app.all('/getQuotedMessage/:messageId', async (req, res) => {
  try {
    // Obtener el mensaje por su ID
    const message = await client.getMessageById(req.params.messageId);
    
    if (!message) {
      return res.status(404).send("Message not found");
    }

    // Verificar si el mensaje tiene una respuesta (quotedMsg)
    if (message.hasQuotedMsg) {
      const quotedMessage = await message.getQuotedMessage();

      // Devolver la información del mensaje citado
      return res.json({
        originalMessage: message.body,
        quotedMessage: {
          id: quotedMessage.id._serialized,
          body: quotedMessage.body,
          from: quotedMessage.from
        }
      });
    } else {
      return res.status(404).send("No quoted message found");
    }
  } catch (ex) {
    if (!res.headersSent) {
      res.status(500).send(ex.message);
    }
  }
});

app.post('/setStatusInfo/:statusMsg', async (req, res) => {
  try {
    await client.setStatus(req.params.statusMsg)
    res.status(200).json({
      "response": "ok"
    });
  } catch (ex) {
    if (!res.headersSent) {
      res.status(500).send(ex.message);
    }
  }
})

app.post('/deleteMessage/:messageId/:everyone', async (req, res) => {
  try {
    const message = await client.getMessageById(req.params.messageId);
    
    if (!message) {
      return res.status(404).send("Message not found");
    }

    const response = await message.delete(req.params.everyone == 2);
    res.status(200).json({
      "response": response
    });
  } catch (ex) {
    if (!res.headersSent) {
      res.status(500).send(ex.message);
    }
  }
})

const delay = (delayInms) => {
  return new Promise(resolve => setTimeout(resolve, delayInms));
};

client.initialize();
app.listen(7301)