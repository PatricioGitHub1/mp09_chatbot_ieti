const express = require('express')
const multer = require('multer');
const url = require('url')

const app = express()
const port = process.env.PORT || 3000

// Configurar la rebuda d'arxius a través de POST
const storage = multer.memoryStorage(); // Guardarà l'arxiu a la memòria
const upload = multer({ storage: storage });

// Tots els arxius de la carpeta 'public' estàn disponibles a través del servidor
// http://localhost:3000/
// http://localhost:3000/images/imgO.png
app.use(express.static('public'))

// Configurar per rebre dades POST en format JSON
app.use(express.json());

// Activar el servidor HTTP
const httpServer = app.listen(port, appListen)
async function appListen() {
  console.log(`Listening for HTTP queries on: http://localhost:${port}`)
}

// Tancar adequadament les connexions quan el servidor es tanqui
process.on('SIGTERM', shutDown);
process.on('SIGINT', shutDown);
function shutDown() {
  console.log('Received kill signal, shutting down gracefully');
  httpServer.close()
  process.exit(0);
}


// Configurar direcció tipus 'POST' amb la URL ‘/data'
// Enlloc de fer una crida des d'un navegador, fer servir 'curl'
// curl -X POST -F "data={\"type\":\"test\"}" -F "file=@package.json" http://localhost:3000/data



// curl -X POST -F "data={\"type\":\"conversa\"}" -F "file=@package.json" http://localhost:3000/prueba
app.post('/chat', upload.single('file'), async (req, res) => {
  // Procesar los datos del formulario JSON
  const objPost = req.body;
  const uploadedFile = req.file;
  var ResponseText;
  console.log("Mensaje recibido:", objPost.type); // Mensaje enviado desde Flutter
  if (objPost.type === 'conversa') {
    console.log("Esto es de tipo conversa");
    console.log("Mensaje recibido:", objPost.message); // Mensaje enviado desde Flutter

    //postMistral(objPost.message, res);
    res.status(200).json({ success: true, message: "Solicitud de conversa recibida correctamente" });
    // Aquí puedes realizar acciones necesarias con el mensaje y el archivo, almacenarlo en una base de datos, etc.
    //res.status(200).json({ success: true, message: 'ds' });
  } else if (objPost.type === 'imatge') {
    console.log("Esto es de tipo imatge");
    console.log("Mensaje recibido:", objPost.message); // Mensaje enviado desde Flutter
    console.log("Imagen recibida:", uploadedFile.originalname); // Nombre del archivo enviado desde Flutter
    // Aquí puedes manejar la solicitud para imágenes si es necesario

    res.status(200).json({ success: true, message: "Solicitud de imagen recibida correctamente" });
  } else {
    res.status(400).json({ success: false, error: 'Solicitud incorrecta.' });
  }
});

async function postMistral(prompt, res) {
  const url = "http://localhost:11434/api/generate";
  const data = {"model":"mistral", "prompt": prompt};

  fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(data),
  })
    .then(async response => {
      if (!response.ok) {
        throw new Error(`HTTP error! Status: ${response.status}`);
      }
      const allResponses = await response.text();
      const txt = createSingleResponse(allResponses);
      res.status(200).json({ success: true, message: txt });
    })
    
    .catch(error => {
      console.error('Error:', error);
      res.status(400).json({ success: false, error: 'Something went wrong....' });
    });
}

function createSingleResponse(allresp) {
  const lista = allresp.split('\n');
  var final_text = '';
  lista.forEach(item => {
    try {
      const jsonRes = JSON.parse(item);
      final_text += jsonRes['response'];
    } catch (error) {
      console.log("end of process");
    }
  });

  return final_text;
}