Q = require 'q'

module.exports = class App
  constructor:()->
    @_modules = []
    @_configs = {}
    http = null
  setConfig : (name, value)->
    #!TODO Maybe some work on this... No rewrite env ?
    @_configs[name] =
      value:value
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
  _middleware : []
  middleware :()->
    init = @module('init/init')
    _ = @
    return (req,res,next)->
      i = -1
      myNext = ()->
        i++
        if _._middleware[i]?
          _._middleware[i](req,res,myNext)
        else
          next()
      #TODO Fail does not work here ? Why ?
      init.then(myNext).fail((error)->
        console.log "INIT FAILT"
        res.render 'error', error:error
        #res.send "Init Error #{error.message}"
      )
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
        "/#{name}"
        "The path of the module #{name}"
      ).then((modulePath)->
        #console.log "Loading Module #{name}"
        Module = require(__dirname + modulePath)
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
        )
      ).fail((error)->
        defer.reject(error)
      )
    return defer.promise
  #
  # This function use the configs to validate by regex the strings
  #
  validate : (string, name, regex)->
    return @config(
      'regex_'+name,
      regex,
      '/^.*$/i', "The regex to validate #{name} string"
    ).then((regex)->
      if not regex?
        console.log "ERROR REGEX #{name} NOT DEFINED !"
      return string
    )
  run: ()->
    return Q.when(true)

###
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
###
