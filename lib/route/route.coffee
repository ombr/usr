Q = require 'q'
module.exports = class Route
  auth : ()->
    _ = @
    # Authentification process
    @deps.app.get('/login*',(req,res)->
      _.deps.usr.module('auth').then((auth)->
        auth.getLogin(req,res)
      )
    )
    @deps.app.post('/login/local',(req,res,next)->
      _.deps.usr.module('auth').then((auth)->
        auth.postLoginLocal(req,res,next)
      )
    )
    # OAuth2 End points
    @deps.app.get('/oauth2/authorize',(req,res,next)->
      _.deps.usr.module('oauth2').then((oauth2)->
        oauth2.authorize(req,res,next)
      )
    )
    @deps.app.post('/oauth2/token',(req,res,next)->
      _.deps.usr.module('oauth2').then((oauth2)->
        oauth2.token(req,res,next)
      )
    )
  init : (@deps)->
    @auth()
    return Q.when(true)
