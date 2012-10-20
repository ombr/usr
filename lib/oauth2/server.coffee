# Errros
class OAuthError extends Error
class InvalidRequest extends OAuthError
class AccessDenied extends OAuthError
class UnsupportedResponseType extends OAuthError
class InvalidScope extends OAuthError
class ServerError extends OAuthError
class TemporarilyUnavailable extends OAuthError

module.exports = class Server

  SESSION_NAME    : 'USROAUTH'
  REGEX :
    client_id   : '[a-zA-Z0-9]{1,100}'
    client_secret : '[a-zA-Z0-9]{1,100}'
    redirect_uri  : null
    response_type : 'code'#Currently only code is supported
    scope     : '([a-zA-Z]{1,100})*'#TODO Be compliant with
    #scope = scope-token *( SP scope-token ) and scope-token = 1*NQCHAR
    state     : '[a-zA-Z0-9]*'#TODO Be full compliant with
    #def : state    = 1*VSCHAR
    code      : '[a-zA-Z0-9]{1,100}'
    grant_type  : 'authorization_code'

  DEFAULT_SCOPE : ''
  TOKEN_TYPE  : 'bearer'

  #Function to implement...
  store : (namespace, datas, cb)->
    throw new ServerError('You should implement this function')
  get : (namespace, id, cb)->
    throw new ServerError('You should implement this function')
  delete : (namespace ,id)->
  
  getClientURIs : (client_id, cb)->
    throw new ServerError('You should implement this function')
  getClientResponseType : (client_id, cb)->
    throw new ServerError('You should implement this function')
  loginClient : (client_id, client_password, cb)->
    throw new ServerError('You should implement this function')
  
  check : (datas, name)->
    if @REGEX[name] != null
      if true #TODO check REGEX
        return datas[name]
      else
        throw new InvalidRequest(
          "Param #{name} is not matching the regex #{@REGEX[name]}"
        )
    return datas[name]
  _getUri : (args, cb)->
    @getClientURIs(args['client_id'], (err, uris)->
      if err
        throw new ServerError('Unable to retrive clients URI')
      if not args['redirect_uri']?
        if uris[0]
          return cb(uris[0])
      for u in uris
        #!TODO Improve with domain check, patern,...
        if args['redirect_uri'] == u
          return cb(u)
      throw new InvalidRequest('Uri is not valid for this client')
    )

  authInit : (session, params, cb)->
    try
      _ = @
      args = session[@SESSION_NAME] =
        client_id   : @check(params, 'client_id')
        response_type : @check(params, 'response_type')
        redirect_uri  : @check(params, 'redirect_uri')
        scope     : @check(params, 'scope') || @DEFAULT_SCOPE
        state     : @check(params, 'state')
      _.getClientResponseType(args['client_id'], (err,response_types)->
        if err
          throw new ServerError('Unable to retrive clients response_types')
        if not args['response_type'] in response_types
          throw new UnauthorizedClient(
            "response_type #(args['response_type']} is not "+
            "authorized for this client"
          )
        _._getUri(args, (uri)->
          args['redirect_uri'] = uri
          return cb(null)
        )
      )
    catch e
      #TODO Error To JSON !!!
      return cb(
        e.toString()
      )
  authEnd : (session, userId, cb)->
    _ = @
    #return cb(null,"http://google.fr/")
    args = session[@SESSION_NAME]
    if !args?
      cb(null,"/")
    #TODO Manage Other response_type
    @save('code',
      {
        scope    : args['scope']
        client_id  : args['client_id']
        redirect_uri : args['redirect_uri']
        user_id : userId
      },
      (err,code)->
        if err
          throw ServerError('Unable to create a new code.')
        url = args['redirect_uri']+"?code=#{code}"
        if args['state']
          url+="&state=#{args['state']}"
        return cb(null,url)
    )

  token : (params, cb)->
    try
      _ = @
      args =
        client_id   : @check(params, 'client_id')
        client_secret : @check(params, 'client_secret')
        code      : @check(params, 'code')
        grant_type  : @check(params, 'grant_type')
        redirect_uri  : @check(params, 'redirect_uri')
      _.loginClient(args['client_id'], args['client_secret'], (err,loggued)->
        if err
          throw AccessDenied('The client can not be identified')
        #TODO Timestamp on code.... Invalid code here...
        _.get('code', args['code'], (err, datas)->
          if err
            throw ServerError('Unable to retrieve the code : '+err)
          _.delete('code',args['code'])
          if datas['redirect_uri'] != args['redirect_uri']
            throw InvalidRequest('Wrong redirect_uri')
          if datas['client_id'] != args['client_id']
            throw InvalidRequest('Wrong client_id')
          switch args['grant_type']
            when 'authorization_code'
              _.save('token', {
                user_id  : datas['user_id'],
                scope    : datas['scope'],
                client_id  : datas['client_id'],
              },(err,token)->
                return cb(null,
                  access_token : token,
                  scope:datas['scope']
                  token_type :_.TOKEN_TYPE,
                )
              )
            else
              throw InvalidRequest('Wrong authorization code')
        )
      )
    catch e
      #TODO Error To JSON !!!
      return cb(
        e.toString()
      )
