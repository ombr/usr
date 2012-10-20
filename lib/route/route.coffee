Q = require 'q'
module.exports = class Route
  auth : ()->
    _ = @
    # Authentification process
    @deps.app.get('/login*',(req,res)->
      _.deps.usr.module('auth/auth').then((auth)->
        auth.getLogin(req,res)
      )
    )
    @deps.app.post('/login/local',(req,res,next)->
      _.deps.usr.module('auth/auth').then((auth)->
        auth.postLoginLocal(req,res,next)
      )
    )
    # OAuth2 End points
    @deps.app.get('/oauth2/authorize',(req,res,next)->
      _.deps.usr.module('oauth2/oauth2').then((oauth2)->
        oauth2.authorize(req,res,next)
      )
    )
    @deps.app.post('/oauth2/token',(req,res,next)->
      _.deps.usr.module('oauth2/oauth2').then((oauth2)->
        oauth2.token(req,res,next)
      )
    )

    # User Graph
    @deps.app.get('/me',(req,res,next)->
      _.deps.usr.module('user/user').then((user)->
        user.me(req,res,next)
      )
    )
    #Home redirect to login
    @deps.app.get('/',(req,res,next)->
      if req.user?
        res.send("Hello #{req.user.login} ! How are you ?")
      else
        res.redirect "/login"
    )
  init : (@deps)->
    @auth()
    return Q.when(true)
