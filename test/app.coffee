Async = require 'async'
Log = require 'log'

log = new Log()
configs = require '../configs-test'

express = require 'express'
app = express.createServer(
    express.bodyParser(),
    express.static(__dirname + "/public"),
    express.favicon(),
    express.cookieParser(),
    express.session({ secret: 'supersecret'}),
)
app.log = log

Auth = require '../lib/app'
auth = new Auth(app,configs)

app.get('/', (req, res)->
    res.render('index.jade')
)

app.configure(()->
  app.set('view engine', 'jade')
  app.set('views', __dirname + '/../views')
)

app.listen(configs.app.port)
log.info __dirname
log.info 'Application started http://local.host:'+configs.app.port
module.exports = app
