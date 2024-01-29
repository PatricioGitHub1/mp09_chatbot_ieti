const express = require('express')
const multer = require('multer');
const url = require('url');
const { isNullOrUndefined } = require('util');

var keepStreamAlive;

const app = express()
const port = process.env.PORT || 3000

// Configurar la rebuda d'arxius a través de POST
const storage = multer.memoryStorage(); // Guardarà l'arxiu a la memòria
const upload = multer({ storage: storage });

function isBlank(str) {
  return (!str || /^\s*$/.test(str));
}

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

// Configurar direcció tipus 'GET' amb la URL ‘/itei per retornar codi HTML
// http://localhost:3000/ieti
app.get('/ieti', getIeti)
async function getIeti(req, res) {

  // Aquí s'executen totes les accions necessaries
  // - fer una petició a un altre servidor
  // - consultar la base de dades
  // - calcular un resultat
  // - cridar la linia de comandes
  // - etc.

  res.writeHead(200, { 'Content-Type': 'text/html' })
  res.end('<html><head><meta charset="UTF-8"></head><body><b>El millor</b> institut del món!</body></html>')
}

// Configurar direcció tipus 'GET' amb la URL ‘/llistat’ i paràmetres URL 
// http://localhost:3000/llistat?cerca=cotxes&color=blau
// http://localhost:3000/llistat?cerca=motos&color=vermell
app.get('/llistat', getLlistat)
async function getLlistat(req, res) {
  let query = url.parse(req.url, true).query;

  // Aquí s'executen totes les accions necessaries
  // però tenint en compte els valors dels variables de la URL
  // que guardem a l'objecte 'query'

  if (query.cerca && query.color) {
    // Així es retorna un text per parts (chunks)
    res.writeHead(200, { 'Content-Type': 'text/plain; charset=UTF-8' });
    await new Promise(resolve => setTimeout(resolve, 1000))
    res.write(`result: "Aquí tens el llistat de ${query.cerca} de color ${query.color}"`)
    await new Promise(resolve => setTimeout(resolve, 1000))
    res.write(`\n list: ["item0", "item1", "item2"]`)
    await new Promise(resolve => setTimeout(resolve, 1000))
    res.end(`\n end: "Això és tot"`)
  } else {
    // Així es retorna un objecte JSON directament
    res.status(400).json({ result: "Paràmetres incorrectes" })
  }
}
// Cerrar stream
app.post('/close', async (req, res) => {
  console.log('closing stream to client...')
  keepStreamAlive = false;
})

// Configurar direcció tipus 'POST' amb la URL ‘/data'
// Enlloc de fer una crida des d'un navegador, fer servir 'curl'
// curl -X POST -F "data={\"type\":\"test\"}" -F "file=@package.json" http://localhost:3000/data
app.post('/data', upload.single('file'), async (req, res) => {
  // Processar les dades del formulari i l'arxiu adjunt
  keepStreamAlive = true;
  const textPost = req.body;
  const uploadedFile = req.file;
  let objPost = {}

  try {
    objPost = JSON.parse(textPost.data)
  } catch (error) {
    res.status(400).send('Sol·licitud incorrecta.')
    console.log(error)
    return
  }

  // Aquí s'executen totes les accions necessaries
  // però tenint en compte el tipus de petició 
  // (en aquest exemple només 'test')

  // A l'exercici 'XatIETI' hi hauràn dos tipus de petició:
  // - 'conversa' que retornara una petició generada per 'mistral'
  // - 'imatge' que retornara la interpretació d'una imatge enviada a 'llava'

  if (objPost.type === 'conversa') {
    console.log("en conversa...");
    res.writeHead(200, { 'Content-Type': 'text/plain; charset=UTF-8' })
    const url = "http://localhost:11434/api/generate";
    const data = {"model":"mistral", "prompt": objPost.message};

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
        const reader = response.body.getReader();
        keepStreamAlive = true;
        while (keepStreamAlive) {
            const { done, value } = await reader.read();

            if (done) {
              break;
            }
            
            if (value != null) {
              const jsonString = new TextDecoder().decode(value);
              separatedJsonArray = jsonString.split("\n");
              console.log('Raw JSON:', jsonString);
              separatedJsonArray = separatedJsonArray.filter(e => e !== '')
              console.log(separatedJsonArray);

              if (separatedJsonArray.length > 1) {
                for (let index = 0; index < separatedJsonArray.length; index++) {
                  const element = separatedJsonArray[index];
                  const jsonData = JSON.parse(element);
                  console.log(jsonData.response);
                  res.write(jsonData.response);
                }
              } else {
                const jsonData = JSON.parse(jsonString);
                console.log(jsonData.response);
                res.write(jsonData.response);
              }
              
            }
            
        }

        res.end("") 
      })
       
      .catch(error => {
        console.error('Error:', error);
        res.status(400).json({ success: false, error: 'Something went wrong....' });
      });
  } else if (objPost.type === 'imatge') {
    console.log("en imatge...");
    let fileContent = uploadedFile.buffer.toString('base64');
    res.writeHead(200, { 'Content-Type': 'text/plain; charset=UTF-8' })
    const url = "http://localhost:11434/api/generate";
    // model
    var textImagePrompt = objPost.message
    if (isBlank(textImagePrompt)) {
      console.log("texto vacio");
      textImagePrompt =  "describe this image";
    }
    const data = {"model":"llava", "prompt": textImagePrompt, "images":[fileContent]};

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 600000);
    console.log('created timeout controller..');
    fetch(url, {
      method: 'POST', 
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
      signal: controller.signal,
    })
      .then(async response => {
        clearTimeout(timeoutId);
        if (!response.ok) {
          throw new Error(`HTTP error! Status: ${response.status}`);
        }
        const reader = response.body.getReader();
        keepStreamAlive = true;
        while (keepStreamAlive) {
            const { done, value } = await reader.read();

            if (done) {
              break;
            }

            if (value != null) {
              const jsonString = new TextDecoder().decode(value);
              separatedJsonArray = jsonString.split("\n");
              console.log('Raw JSON:', jsonString);
              separatedJsonArray = separatedJsonArray.filter(e => e !== '')
              console.log(separatedJsonArray);

              if (separatedJsonArray.length > 1) {
                for (let index = 0; index < separatedJsonArray.length; index++) {
                  const element = separatedJsonArray[index];
                  const jsonData = JSON.parse(element);
                  console.log(jsonData.response);
                  res.write(jsonData.response);
                }
              } else {
                const jsonData = JSON.parse(jsonString);
                console.log(jsonData.response);
                res.write(jsonData.response);
              }
              
            }
            
        }

        res.end("") 
      })
      
      .catch(error => {
        console.error('Error:', error);
        res.status(400).json({ success: false, error: 'Something went wrong....' });
      });
    
  } else {
    res.status(400).send('Sol·licitud incorrecta.')
  }

  keepStreamAlive = false;
})