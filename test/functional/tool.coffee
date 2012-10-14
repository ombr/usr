Usr = require '../../index'
express = require 'express'
http = require 'http'
path = require 'path'
tobi = require 'tobi'
Browser = require 'zombie'
Q = require 'q'

module.exports = class Tool
  clientApp : ()->
    console.log "CLIENT APP"
    #Configuration of your express app
    Passport = require('passport').Passport
    OAuth2Strategy = require('passport-oauth').OAuth2Strategy
    passport = new Passport()
    passport.use('usr',
        new OAuth2Strategy(
          {
            authorizationURL: 'http://local.host:3000/oauth2/authorize',
            tokenURL: 'http://local.host:3000/oauth2/token',
            clientID: 'myApp',
            clientSecret: 'shhh-its-a-secret'
            callbackURL: 'http://local.host:3001/auth/usr/callback'
          },
          (accessToken, refreshToken, profile, done)->
            return done(null,{
              login:"ombr"
            })
        )
    )

    passport.serializeUser((user, done)->
      console.log "SESSION SAVE"
      console.log user
      done(null, user.login)
    )

    passport.deserializeUser((id, done)->
      return done(null, {
        login:"ombr"
        password:"SDFSDF"
      })
      done(null, {
        login:"ombr"
      })
    )
    app = express()
    app.configure(()->
      app.set('port', 3001)
      app.set('views', __dirname + '/../../views')
      app.set('view engine', 'jade')
      app.use(express.logger('dev'))
      app.use(express.cookieParser())
      app.use(express.bodyParser())
      app.use(express.session(secret:"TEST"))
      app.use(passport.initialize())
      app.use(passport.session())
      app.use(express.methodOverride())
      app.use(app.router)
    )








    #authentification on home page.
    app.get('/',
      (req,res, next)->
        if req.user?
          res.send("Hello #{req.user.login}")
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
    server = http.createServer(app)
    server.listen(3001)
    return Q.when(
      app:app,
      url:'http://127.0.0.1:3001/'
      server:server
    )


  start:()->
    deferred = Q['defer']()

    #
    # Server App
    #
    app = express()
    app.configure(()->
      app.set('port', process.env.PORT || 3000)
      app.set('views', __dirname + '/../../views')
      app.set('view engine', 'jade')
      app.use(express.favicon())
      app.use(express.logger('dev'))
      app.use(express.bodyParser())
      app.use(express.cookieParser())
      app.use(express.session(secret:"TEST"))
      app.use(express.methodOverride())
      app.use(app.router)
    )

    server = http.createServer(app)

    Usr = require '../../index'
    usr = new Usr()
    usr.app = app
    app.server = server
    usr.run()





    server.listen(app.get('port'), ()->
      Browser.debug = true
      browser = new Browser()
      deferred.resolve(
        app:app
        server:server
        url:'http://127.0.0.1:'+app.get('port')
        browser:browser
      )
    )
    return deferred.promise
  delete:(app)->
    app.close()

#tool = new Tool()
#tool.clientApp()
#tool.start()
