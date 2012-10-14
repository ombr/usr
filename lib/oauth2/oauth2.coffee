Q = require 'q'

module.exports = class OAuth2
  init : (@deps)->
    OAuthServer = require './server'
    @server = new OAuthServer()


    store={
      i:0
    }
    @server.save = (namespace, datas, cb)->
      console.log "SAVE"
      console.log namespace
      d =
        datas : datas
        namespace : namespace
      id = store.i++
      store[id] = d
      return cb(null,id)

    @server.delete = (namespace, id)->
      delete store[id]

    @server.get = (namespace, id, cb)->
      console.log "GET "
      console.log namespace
      if store[id]?
        return cb(null, store[id]["datas"])
      return cb(['Not found'], null)

    @server.loginClient = (client_id, client_password, cb)->
      if client_id == 'myApp' && client_password == 'mySecret'
        return cb(null,true)
      return cb(['Access denied'], false)

    @server.getClientURIs = (clientId, cb, uriProvided)->
      console.log "GETCLIENTURI"
      if clientId == 'myApp'
        console.log "GETCLIENTURI OK"
        return cb(null, ['http://local.host:3001/auth/usr/callback'])

    @server.getClientResponseType = (clientId, cb)->
      console.log "RESPONSE TYPE#{clientId}"
      if clientId == 'myApp'
        console.log "CLIENT ID "
        return cb(null,'code')
      return cb(['Access denied'],null)

    return Q.when(true)

  authorize :(req,res,next)->
    params =
      client_id: req.param 'client_id'
      redirect_uri: req.param 'redirect_uri'
      response_type: req.param 'response_type'
      state: req.param 'state'
    console.log "SEVER INIT ?"
    @server.authInit(req.session, params,(err,url)->
      if err?
        return res.send(err+url)
      console.log "authentification INIT OK"
      return res.render 'login'
    )
  endAuthorize :(req,res,next)->
    console.log "END AUTHORIZED "
    #if not req.logguedIn?
      #return res.redirect '/login'
    
    console.log ""
    console.log ""
    console.log ""
    console.log ""
    console.log req.session
    @server.authEnd(req.session, (err,uri)->
      console.log "Auth End ?"
      res.send "Hello World"
      if err?
        return res.redirect '/err'
      return res.redirect uri
    )
  token:(req, res, next)->
    console.log "token"
    params =
      client_id: req.param 'client_id'
      client_secret: req.param 'client_secret'
      redirect_uri: req.param 'redirect_uri'
      code: req.param 'code'
      grant_type: req.param 'grant_type'
    @server.token(params,(err,json)->
      if err?
        return res.send(err)
      console.log "token"
      console.log json
      return res.json(json)
    )

###
  _initServer : ()->
    _ = @

    OAuth2Server = require 'usr-oauth2'
    _.server = new OAuth2Server()

    _.server.save = (namespace, datas, cb)->

    _.server.delete = (namespace, id)->

    _.server.get = (namespace, id, cb)->

    _.server.loginClient = (client_id, client_password, cb)->
      if client_id == 'myApp' && client_password == 'mySecret'
        return cb(null,true)
      return cb(['Access denied'], false)

    _.server.getClientURIs = (clientId, cb, uriProvided)->
      if clientId == 'myApp'
        return cb(null, ['http://local.host:3001/auth/usr/callback'])

    _.server.getClientResponseType = (clientId, cb)->
      if clientId == 'myApp'
        return cb(null,'code')
      return cb(['Access denied'],null)

  _routes : ()->
    
    _ = @

    @routeGet('/oauth2/auth', (req, res)->
      params =
        client_id: req.param 'client_id'
        redirect_uri: req.param 'redirect_uri'
        response_type: req.param 'response_type'
        state: req.param 'state'
      _.server.authInit(req.session, params,(err,url)->
        console.log "Identification initiated #{err}"
        if err?
          return res.send(err+url)
        return res.redirect '/login'
      )
    )
    @routeGet('/oauth2/redirect',(req,res)->
      if not req.logguedIn?
        return res.redirect '/oauth2/auth'
      #TODO manage scope.
      _.server.authEnd(res.session, (err,uri)->
        if err?
          return res.send err + uri
        return res.redirect uri
      )
    )
    @routeGet('/oauth2/info',(req,res)->
      #TODO return real information about the user.
      _.server.get('token', req.param('access_token'), (err,datas)->
        if err?
          return res.json "invalid_token"
        return res.json datas
      )
    )
###
