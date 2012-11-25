express = require 'express'
http = require 'http'

Passport = require('passport').Passport
OAuth2Strategy = require('passport-oauth').OAuth2Strategy
passport = new Passport()
passport.use('usr',
    new OAuth2Strategy(
      {
        authorizationURL: 'http://local.host:3000/oauth2/facebook',
        tokenURL: 'http://local.host:3000/oauth2/token',
        clientID: 'myApp',
        clientSecret: 'shhh-its-a-secret'
        callbackURL: 'http://local.host2:3001/auth/usr/callback'
      },
      (accessToken, refreshToken, profile, done)->
        this._oauth2.getProtectedResource(
          'http://local.host:3000/me',
          accessToken,
          (err,body,res)->
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
