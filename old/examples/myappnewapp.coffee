express = require 'express'
$ = require 'jquery'

app = express.createServer(
  express.bodyParser(),
  express.favicon(),
  express.cookieParser(),
  express.session({ secret: 'supersecret'}),
)

myAppUrl = 'http://127.0.0.1:3001'
usrAppToken = 'lalalal'
usrUrl = "http://local.host:3000"


app.get('/', (req, res)->
  if req.session.user
    user = req.session.user
    res.send("Welcome : #{user.id}, you are in the groups : "+
      "#{user.groups.join(',')}<a href='/logout/'>logout</a>")
  else
    res.send("<a href='#{usrUrl}/login/#{myAppUrl}/logguedIn/'>login</a>")
)

app.get('/logout', (req, res)->
  delete(req.session.user)
  res.redirect(usrUrl+"/logout/#{myAppUrl}")
)

app.get('/logguedIn/:token', (req, res)->
  url = usrUrl+"/info/#{req.params.token}/#{usrAppToken}"
  $.getJSON(url,(datas)->
    req.session.user = datas
    res.redirect('/')
  )
)

app.listen(3001)
