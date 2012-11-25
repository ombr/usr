express = require('express')
http = require('http')
https = require('https')
path = require('path')
fs = require 'fs'




app = express()
server = http.createServer(app)
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


server.listen(app.get('port'), ()->
  console.log "SERVER STARTED"+app.get('port')
)

options = {
  key: fs.readFileSync(__dirname+'/local.host.key'),
  cert: fs.readFileSync(__dirname+'/local.host.csr')
}
#https.createServer(options, app).listen(4443)
