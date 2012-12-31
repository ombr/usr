Q = require 'q'

module.exports = class Init
  init:(@deps)->
    usr = @deps.usr
    defered = Q.defer()
    @_providers().then(()->
      return Q.all([
        usr.module("event/event"),
        usr.module("route/route"),
        usr.module("auth/auth"),
        usr.module("oauth2/oauth2"),
        usr.config(
          "module/store/user",
          "/store/store",
          "Store for users."
        ),
        usr.config("module/store/password",
        "/store/store",
        "Store for passwords."
        ),
        usr.config(
          "module/store/oauth2/code",
          "/store/store",
          "Store for oauth2 code."
        ),
        usr.config(
          "module/store/oauth2/token",
          "/store/store",
          "Store for oauth2 token"
        )
      ])
    ).then((res)->
      event = res[0]
      event.once('user/login',(datas)->
        console.log "FIRST LOGIN :-D "
        #We should check here if there is only one user, and if there
        #is grant him admin right :-D
        console.log datas
      )
      defered.resolve()
    ).fail((error)->
      defered.reject(error)
    )
    return defered.promise
  _providers :()->
    return Q.all([
      @_provider('facebook')
    ])
  _provider:(provider)->
    usr = @deps.usr
    return Q.all([
      usr.config(
        'provider_'+provider+'_id',
        null,
        "This is the #{provider} app identifier"
      )
      usr.config(
        'provider_'+provider+'_secret',
        null,
        "This is the #{provider} app secret"
      )
    ]).then((identifiers)->
      [id,secret] = identifiers
      console.log provider
      console.log id
      console.log secret
      if id? and secret?
        console.log "#{provider} ENABLED !"
        console.log 'provider_'+provider+'_enabled'
        usr.setConfig('provider_'+provider+'_enabled',true)
        console.log "SET"
        usr.setConfig('providers_enabled',true)
    )

