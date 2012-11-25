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

  SESSION_NAME : 'USROAUTH2'
  TOKEN_TYPE  : 'bearer'
  start : ()->
    _ = @
    usr = @deps.usr
    return (req, res, next)=>
      if req.session[_.SESSION_NAME]?
        req.oauth2 = req.session[_.SESSION_NAME]
        return next()
      Q.all([
        Q.all([
          usr.validate(req.param('client_id'), 'login')
          usr.validate(req.param('redirect_uri'), 'url')
          usr.validate(
            req.param('response_type'),
            'oauth2_response_type',
            'TODO REGEX'
          )
          usr.validate(req.param('scope'), 'oauth2_scope', 'TODO REGEX')
          usr.validate(req.param('state'), 'oauth2_state', 'TODO REGEX')
        ]),
        usr.module('store/user')
      ]).then((res)->
        [params,store] = res
        [client_id, redirect_uri, response_type, scope, state] = params
        store.findOneBy(
          id:client_id
        ).then((client)->
          #!TODO CHECK redirect_uri
          req.session[_.SESSION_NAME] =
              client_id: client_id
              redirect_uri: redirect_uri
              response_type: response_type
              scope: scope
              state: state
          next()
        ).fail(()->
          throw new Error("client_id not found.")
        )
      ).fail((error)->
        #!TODO ERROR
        res.render('error',error:error)
      )
  end: ()->
    return (req, res, next)=>
      if not req.oauth2?
        return res.render('error',
          error:new Error("You must init oauth2 first.")
        )
      if !req.isAuthenticated()
        return res.render('error',error:new Error("User must be loggued in !"))
      @deps.usr.module('store/oauth2/code').then((codes)->
        datas = req.oauth2
        datas['user_id'] = req.user.usr_id
        codes.add(req.oauth2).then((code)->
          res.redirect req.oauth2.redirect_uri+"?code=#{code}"
        )
      ).fail((error)->
        res.render('error',error:error)
      )
    #@server.authEnd(req.session, req.user.id, (err,uri)->
      #if err?
        #return res.redirect '/err'
      #return res.redirect uri
    #)
    
  token: (req, res, next)->
    _ = @
    usr = @deps.usr
    Q.all([
      Q.all([
        usr.validate(req.param('client_id'), 'login')
        usr.validate(req.param('client_secret'), 'login')
        usr.validate(req.param('redirect_uri'), 'url')
        usr.validate(req.param('code'), 'code')
        usr.validate(req.param('grant_type'), 'grant_type')
      ]),
      usr.module('store/oauth2/code')
      usr.module('store/user')
    ]).then((result)->
      [params,codes, users] = result
      [client_id, client_secret, redirect_uri, code, grant_type] = params
      codes.get(code).then((oauth2)->
        if oauth2.client_id != client_id
          throw new Error("Code Invalid for this clientI Id")
        if oauth2.redirect_uri != redirect_uri
          throw new Error("Redirect_uri invalid for this code")
        #TODO Validate client_secret ??
        switch grant_type
          when 'authorization_code'
            usr.module('store/oauth2/token').then((tokens)->
              tokens.add(
                user_id: oauth2.user_id
                client_id: client_id
                scope: oauth2.scope
              ).then((token)->
                res.json(
                  access_token : token,
                  refresh_token : token,
                  scope: oauth2.scope
                  token_type: _.TOKEN_TYPE
                )
              )
            )
          else
            throw Error('grant_type not recognized')
      )
    ).fail((error)->
      console.log "ERROR ICI TO JSON ??"
      console.log error
    )
  authorize_old :(req,res,next)->
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
  endAuthorize_old:()->
    return (req,res,next)=>
      if !req.isAuthenticated()
        return res.redirect '/login'
      @server.authEnd(req.session, req.user.id, (err,uri)->
        if err?
          return res.redirect '/err'
        return res.redirect uri
      )
  token_old:(req, res, next)->
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
