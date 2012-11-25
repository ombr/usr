Usr = require '../../index'
express = require 'express'
http = require 'http'
path = require 'path'
Browser = require 'zombie'
Q = require 'q'

module.exports = class Tool
  tool : ()->
    deferred = Q.defer()
    res = {}
    #
    # Server App
    #
    app = express()
    app.set('port', process.env.PORT || 3000)
    app.set('views', __dirname + '/../../views')
    app.set('view engine', 'jade')
    app.use(express.logger('dev'))
    app.use(express.favicon())
    app.use(express.cookieParser())
    app.use(express.bodyParser())
    app.use(express.session(secret:"TEST"))

    Usr = require '../../index'
    usr = new Usr()
    usr.app = app
    app.server = server
    app.use(usr.middleware())
    app.use(express.methodOverride())
    app.use(app.router)

    serverUsr = http.createServer(app)
    res['app'] = app
    res['usr'] = usr
    res['server'] = server
    res['browser'] = new Browser()
    res['url'] = 'http://local.host:'+app.get('port')

    #
    # Configuration of your express test app
    #
    Passport = require('passport').Passport
    OAuth2Strategy = require('passport-oauth').OAuth2Strategy
    passport = new Passport()

    usr.module('init/init').then((init)->
      usr.module('store/user').then((users)->
        users.add(
          id:'myApp'
        ).then((datas)->
          console.log "App added !"
        )
      )
    )
    passport.use('usr',
        new OAuth2Strategy(
          {
            authorizationURL: res['url']+'/oauth2/facebook',
            tokenURL: res['url']+'/oauth2/token',
            clientID: 'myApp',
            clientSecret: 'shhh-its-a-secret'
            callbackURL: 'http://127.0.0.1:3001/auth/usr/callback'
          },
          (accessToken, refreshToken, profile, done)->
            console.log "LOADED !"
            console.log accessToken
            console.log refreshToken
            console.log profile
            this._oauth2.getProtectedResource(
              'http://local.host:3000/me',
              accessToken,
              (err,body,res)->
                console.log "TEST !!!"
                console.log body
                user = JSON.parse(body)
                done(null,user)
            )
        )
    )

    passport.serializeUser((user, done)->
      done(null, JSON.stringify(user))
    )
    passport.deserializeUser((id, done)->
      done(null, JSON.parse(id))
    )


    app = express()
    app.set('port', 3001)
    app.set('views', __dirname + '/../../../views')
    app.set('view engine', 'jade')
    app.use(express.logger('dev'))
    app.use(express.cookieParser())
    app.use(express.bodyParser())
    app.use(express.session(secret:"TEST"))
    app.use(passport.initialize())
    app.use(passport.session())
    app.use(express.methodOverride())
    app.use(app.router)

    app.get('/',
      (req,res, next)->
        if req.user?
          res.send("Hello <div id='login'>#{req.user.displayName}</div>")
        else
          passport.authenticate('usr')(req,res,next)
    )

    app.get('/error',(req,res)->
      res.send('An Error has occured ;-(')
    )
    app.get('/auth/usr/callback',
      passport.authenticate('usr',
        {
          successRedirect: '/',
          failureRedirect: '/error'
        }
      )
    )

    res['client'] = app
    res['clientUrl'] = 'http://127.0.0.1:3001/'
    res['clientServer'] = server

    server = http.createServer(app)
    serverUsr.listen(3000, ()->
      server.listen(3001,()->
        deferred.resolve(res)
      )
    )
    return deferred.promise

tool = new Tool()
tool.tool().then((res)->
  console.log res['clientUrl']
  console.log res['url']
)
###
tool = new Tool()
Q.all([
  tool.start(),
  tool.clientApp()
]).then((res)->
  res[0].server.close()
  res[1].server.close()
  console.log "DELETED OK :-D"
  Q.all([
    tool.start(),
    tool.clientApp()
  ]).then((res)->
    console.log "Re Started :-D"
  )
)
