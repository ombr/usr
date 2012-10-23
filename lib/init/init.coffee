Q = require 'q'

module.exports = class Init
  init:(@deps)->
    usr = @deps.usr
    defered = Q.defer()
    Q.all([
      usr.config(
        "module/store/user",
        "./store/store",
        "Store for users."
      ),
      usr.config("module/store/password",
      "./store/store",
      "Store for passwords."
      ),
      usr.config(
        "module/store/oauth2/code",
        "./store/store",
        "Store for oauth2 code."
      ),
      usr.config(
        "module/store/oauth2/token",
        "./store/store",
        "Store for oauth2 token"
      ),
      usr.module("route/route"),
      usr.module("auth/auth")
    ]).then(()->
      defered.resolve()
    ).fail((error)->
      console.log "ERROR INIT FAIL..."
      console.log error
    )

