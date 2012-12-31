Q = require 'q'
module.exports = class Route
  auth : ()->
    _ = @

    home = (req,res,next)->
      if not req.user?
        return res.send("USR AUTHENTICATION END POINT.")
      else
        return res.json req.user


    ###
    # User Interface point :
    ###

    #Home sweet home
    @deps.app.get('/',home)

    #Login end point :
    Q.all([
      _.deps.usr.module('auth/auth'),
      _.deps.usr.module('oauth2/oauth2')
    ]).then((res)->
      [auth,oauth2] = res
      authenticate =  (req,res,next)->
        #TODO params provider.
        auth.auth(req.param('provider'))(req,res,()->
          oauth2.end()(req,res,()->
            home(req,res,next)
            #we were not authenticating with Oauth2... Let's do something
            #else...
            #res.render('error',
              #error:
                #new Error("Oh no....I don't know where I should get you...")
            #)
          )
          _.deps.usr.module('event/event').then((events)->
            events.emit('user/login', req.user)
          )

        )
      _.deps.app.get('/auth/:provider',oauth2.start(), authenticate)
      _.deps.app.post('/auth/:provider',oauth2.start(), authenticate)
    )


    ###
    # OAUTH2 ENDPOINT
    ###

    #Token end point.
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


    ###
    # API end points :
    ###

    # User Graph
    @deps.app.get('/me',(req,res,next)->
      _.deps.usr.module('user/user').then((user)->
        user.me(req,res,next)
      )
    )
  init : (@deps)->
    @auth()
    return Q.when(true)
