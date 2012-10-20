EventEmitter = require('eventemitter2').EventEmitter2
Q = require 'q'

module.exports = class App
  _modules : []
  _configs : {}
  http : null
  config : (name, def, description)->
    if process.env[name]?
      return Q.when(process.env[name])
    if @_configs[name]?
      return Q.when(@_configs[name].value)
    @_configs[name] =
      value : def
      description : description
    return Q.fcall(()->
      return def
    )
  log : console.log
  constructor : ()->
    return
  _middleware : []
  middleware :()->
    defered = Q.defer()
    Q.all([
      @config("module/store/user", "./store/store", "Store for users."),
      @config("module/store/password", "./store/store", "Store for passwords."),
      @config(
        "module/store/oauth2/code",
        "./store/store",
        "Store for oauth2 code."
      ),
      @config(
        "module/store/oauth2/token",
        "./store/store",
        "Store for oauth2 token"
      ),
      @module("route/route"),
      @module("auth/auth")
    ]).then(()->
      defered.resolve()
    ).fail((error)->
      console.log "ERROR LOADING USR :"
      console.log error
    )
    _ = @
    return (req,res,next)->
      i = -1
      myNext = ()->
        i++
        if _._middleware[i]?
          _._middleware[i](req,res,myNext)
        else
          next()
      defered.promise.then(myNext)
  #
  # Here is the shortcut to load a module
  # Module are loaded by reading the config.
  #
  module : (name)->
    _ = @
    #console.log "Get Module #{name}"
    defer = Q.defer()
    if _._modules[name]?
      defer.resolve(_._modules[name])
    else
      @config(
        "module/#{name}",
        "./#{name}"
        "The path of the module #{name}"
      ).then((modulePath)->
        #console.log "Loading Module #{name}"
        Module = require(modulePath)
        module = new Module
        _._modules[name] = module
        module.app = _
        #console.log "INIT"
        module.init(
          app : _.app
          usr : _
        ).then(()->
          #console.log "Module #{name} loaded"
          defer.resolve(module)
        ).end()
      ).end()
    return defer.promise
  #
  # This function use the configs to validate by regex the strings
  #
  validate : (name, string)->
    return @config(
      'regex-'+name,
      '/^.*$/i', "The regex to validate #{name} string"
    ).then((regex)->
      return string
      return string.match(regex)
    )
  run: ()->
    return Q.when(true)
    defer = Q.defer()
    return defer.promise

    _ = @
    if not @configs.logger?
      Log = require 'log'
      @log = new Log("warning")
    else
      @log = @configs.logger

    @_event = new EventEmitter(
      wildcard:true
    )
    @_event.on('*',(infos)->
      _.log.debug "EVENT #{@event} : #{JSON.stringify(infos)}"
    )

    #!TODO move this function to access...
    @_event.once('token/new',(datas)->
      _.log.debug "First token created, _root init ?"
      _.stores.group.findGroupByName('root',(err,group)->
        if group == null
          _.stores.group.addGroup('_root',(err,groupId)->
            _.emit('group/new',
              groupId : groupId
              token : datas.token
            )
            _.stores.group.addUserToGroup(datas.userId,groupId,(err,res)->
              _.emit('group/addUser',
                groupId : groupId
                token : datas.token
                userId : datas.userId
              )
              _.stores.group.addUserToGroupCache(
                datas.userId,groupId,
                (err,res)->
                  if !res
                    throw new Error("Error root access granted...")
                    # Might be a bit strange, but
                    # root seems to proclam himself root
                    _.emit('root/new',datas)
              )
            )
          )
      )
    )
    #Init stores :
    @stores = {}
    for store,configs of @configs.stores
      StoreClass = require '../'+configs.class
      @stores[store] = new StoreClass(configs.configs)
    #!TODO Check If stores are OK (user, token, group)

    #Init modules
    modules =
      'auth' : './auth/auth'
      'user' : './user/user'
      'group' : './group/group'
      'token' : './token/token'
      'access' : './access/access'
      'event' : './event/event'
    for name,file of modules
      @log.info "Load #{file} as #{name}"
      Module = require file
      @[name] = new Module(@)
