Q = require 'q'

module.exports = class OAuth2
  init : (@deps)->
    _ = @
    usr = @.deps.usr
    OAuthServer = require './server'
    @server = new OAuthServer()


    store={
      i:0
    }
    @server.save = (namespace, datas, cb)->
      usr.module('store/oauth2/'+namespace).then((store)->
        return store.add(datas)
      ).then((datas)->
        cb(null, datas.id)
      ).fail((error)->
        cb(error,null)
      )

    @server.delete = (namespace, id)->
      usr.module('store/oauth2/'+namespace).then((store)->
        return store.delete(id)
      ).then(()->
      ).fail((error)->
        cb(error,null)
      )

    @server.get = (namespace, id, cb)->
      usr.module('store/oauth2/'+namespace).then((store)->
        return store.get(id)
      ).then((datas)->
        cb(null, datas)
      ).fail((error)->
        cb(error,null)
      )

    @server.loginClient = (client_id, client_password, cb)->
      if client_id == 'myApp' && client_password == 'shhh-its-a-secret'
        return cb(null,true)
      return cb(['Access denied'], false)

    @server.getClientURIs = (clientId, cb, uriProvided)->
      if clientId == 'myApp'
        return cb(null, ['http://local.host2:3001/auth/usr/callback'])

    @server.getClientResponseType = (clientId, cb)->
      if clientId == 'myApp'
        return cb(null,'code')
      return cb(['Access denied'],null)

    return Q.when(true)

  authorize :(req,res,next)->
    _ = @
    params =
      client_id: req.param 'client_id'
      redirect_uri: req.param 'redirect_uri'
      response_type: req.param 'response_type'
      state: req.param 'state'
    @server.authInit(req.session, params,(err,url)->
      if err?
        return res.send(err+url)
      if !req.isAuthenticated()
        return res.render 'login'
      else
        _.endAuthorize(req,res,next)
    )
  endAuthorize :(req,res,next)->
    if !req.isAuthenticated()
      return res.redirect '/login'
    @server.authEnd(req.session, req.user.id, (err,uri)->
      if err?
        return res.redirect '/err'
      return res.redirect uri
    )
  token:(req, res, next)->
    params =
      client_id: req.param 'client_id'
      client_secret: req.param 'client_secret'
      redirect_uri: req.param 'redirect_uri'
      code: req.param 'code'
      grant_type: req.param 'grant_type'
    @server.token(params,(err,json)->
      if err?
        return res.send(err)
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
