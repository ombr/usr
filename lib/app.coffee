
module.exports = class App
    constructor : (express,@configs)->
        _ = @
        Log = require 'log'
        @log = new Log()
        EventEmitter = require('eventemitter2').EventEmitter2
        @_event = new EventEmitter(
            wildcard:true
        )
        @_event.on('*',(infos)->
            _.log.debug "EVENT #{@event} : #{JSON.stringify(infos)}"
        )

        #!TODO move this function to access...
        @_event.once('token/new',(datas)->
            console.log "Check INIT ROOT ?"
            _.stores.group.findGroupByName('root',(err,group)->
                if group == null
                    console.log "ROOT NULL ?"
                    _.stores.group.addGroup('_root',(err,groupId)->
                        _.stores.group.addUserToGroup(datas.userId,groupId,(err,res)->
                            if !res
                                throw "Error root access granted..."
                            _.stores.group.addUserToGroupCache(datas.userId,groupId,(err,res)->
                                if !res
                                    throw "Error root access granted..."
                                _.emit('root/new',datas)
                            )
                        )
                    )
            )
        )
        #@log = @app.log
        @express = express
        @express[ "auth" or @configs.bind] = @ #express binding

        #Init stores :
        @stores = {}
        for store,configs of @configs.stores
            StoreClass = require '../'+configs.class
            @stores[store] = new StoreClass(configs.configs)
        #!TODO Check If stores are OK (user, token, group)

        #Init modules
        modules =
            'auth' : './auth/auth'
            'group' : './group/group'
            'token' : './token/token'
            'access' : './access/access'
            'event' : './event/event'
        for name,file of modules
            console.log "Load #{file} as #{name}"
            Module = require file
            @[name] = new Module(@)

    ###
    #   Helpers used in all application maybe should be removed...
    ###
    error : (req,res)->
        res.json(
            error:true
        )
    ###
    #   Express
    ###
    get : (args...)->
        @app.get(args...)
    post : (args...)->
        @app.post(args...)
    update : (args...)->
        @app.update(args...)
    delete : (args...)->
        @app.delete(args...)

    ###
    #   Events
    ###
    emit : (args...)->
        @event.emit(args...)
    on : (args...)->
        @event.on(args...)
