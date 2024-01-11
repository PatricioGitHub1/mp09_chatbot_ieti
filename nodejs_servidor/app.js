const express = require('express')
const url = require('url')

const app = express()
const port = process.env.PORT || 3000

// Tots els arxius de la carpeta 'public' estàn disponibles a través del servidor
// http://localhost:3000/
// http://localhost:3000/images/imgO.png
app.use(express.static('public'))

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

// Configurar la direcció ‘/itei per retornar codi HTML
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

// Configurar direcció ‘/llistat’ i paràmetres URL 
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
    res.write(`result: "Aquí tens el llistat de ${query.cerca} de color ${query.color}"`)
    res.write(`\n list: ["item0", "item1", "item2"]`)
    res.end(`\n end: "Això és tot"`)
  } else {
    // Així es retorna un objecte JSON directament
    res.status(400).json({ result: "Paràmetres incorrectes" })
  }
}

