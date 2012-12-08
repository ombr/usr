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
    @deps.app.get('/auth/local',(req,res,next)->
      _.deps.usr.module('auth/auth').then((auth)->
        auth.authenticate('local')(req,res,next)
      )
    )

    @deps.app.post('/login/local',(req,res,next)->
      _.deps.usr.module('auth/auth').then((auth)->
        auth.endAuthenticate('local')(req,res,next)
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
    # Facebook provider
    provider = 'facebook'
    @deps.usr.config(
      "provider_#{provider}_enabled",
      false,
      'Is the provider '+provider+' enabled'
    ).then((res)->
      if res
        Q.all([
          _.deps.usr.module('oauth2/oauth2'),
          _.deps.usr.module('auth/auth')
        ]).then((modules)->
          [oauth2,auth] = modules
          _.deps.app.get(
            '/auth/'+provider,
            auth.authenticate(provider)
          )
          _.deps.app.get(
            '/oauth2/'+provider,
            oauth2.start()
            auth.authenticate(provider)
          )
          _.deps.app.get(
            '/auth/'+provider+'/callback',
            oauth2.start(),
            auth.authenticate(provider),
            oauth2.done()
          )
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
