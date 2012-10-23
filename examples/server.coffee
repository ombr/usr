express = require('express')
http = require('http')
https = require('https')
path = require('path')
fs = require 'fs'




app = express()
app.set('port', process.env.PORT || 3000)
app.set('views', __dirname + '/../views')
app.set('view engine', 'jade')
app.use(express.favicon())
app.use(express.static(__dirname+'/../static/'))
app.use(express.cookieParser())
app.use(express.bodyParser())
app.use(express.session(secret:"TEST"))
app.use(express.logger('dev'))

Usr = require '../index'
usr = new Usr()
usr.app = app
app.server = server
app.use(usr.middleware())
app.use(express.methodOverride())
app.use(app.router)

server = http.createServer(app)

server.listen(app.get('port'), ()->
  console.log "SERVER STARTED"
)

options = {
  key: fs.readFileSync('./local.host.key'),
  cert: fs.readFileSync('./local.host.csr')
}
https.createServer(options, app).listen(8080)
