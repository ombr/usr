Usr = require '../lib/app'
configs = require './configs'
express = require 'express'
tobi = require 'tobi'
class Tool

  # Make it with a callback
  app:()->
    app = express.createServer(
      express.bodyParser(),
      express.static(__dirname + "/public"),
      express.favicon(),
      express.cookieParser(),
      express.session({ secret: 'supersecret'}),
    )

    usr = new Usr(app,configs)

    app.configure(()->
      app.set('view engine', 'jade')
      app.set('views', __dirname + '/../views')
    )
    app.listen(configs.app.port)
    #!TODO Make it paralelle and wait for it...
    return usr
  #!TODO Make it with a callback
  delete:(app)->
    app.express.close()
    #delete app
  browser:()->
    tobi.Browser.browsers = {}
    browser = tobi.createBrowser(3001, 'local.host')
    browser.userAgent = 'Mozilla/5.0 (X11; Linux i686) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.100 Safari/534.30'
    return browser
  #Will Return the user or a new user
  user : (app, cb, name)->
    if not name?
      name = @_uniq('user')
    app.auth.addUser('local',name,{},(err,userId)->
      if err != null
        throw "An Error occured"
      cb(userId)
    )
  group: (app, cb, name)->
    if not name?
      name = @_uniq('user')
    app.stores.group.findByName(name,(err,group)->
      if err != null
        app.stores.group.add(name, (err,groupId)->
          cb(groupId)
        )
        return
      cb(group.id)
    )

  token : (app,userId,cb)->
    app.token.add(userId,{}, (err,token)->
      if err != null
        throw "An Error occured"
      cb(token)
    )

  _uniq:(prefix = '')->
    timestamp = new Date().getTime()
    id = Math.round( timestamp+""+Math.round(Math.random()*1000))
    return prefix+id

module.exports = new Tool()
