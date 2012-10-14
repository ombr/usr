express = require('express')
http = require('http')
path = require('path')



console.log "THIS TEST IS DEPRECATED, I will create a new one soon :-D"
###
app = express()

console.log __dirname + '/static/'
app.configure(()->
  app.set('port', process.env.PORT || 3000)
  app.set('views', __dirname + '/../views')
  app.set('view engine', 'jade')
  app.use(express.static(__dirname + '/../static'))
  app.use(express.favicon())
  app.use(express.cookieParser())
  app.use(express.session(secret:"TEST"))
  app.use(express.logger('dev'))
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(app.router)
)

app.configure('development', ()->
  app.use(express.errorHandler())
)

server = http.createServer(app)
server.listen(app.get('port'), ()->
  console.log("Auth server listening on port " + app.get('port'))
)

app.get('/',(req,res)->
  return res.send('Hello World')
)


Usr = require '../index'
Q = require 'q'
usr = new Usr()
usr.app = app
app.server = server
#usr.config = (key, cb)->
    #return Q.fcall(()->
        #return process.env[key]
    #)
usr.run()
###
