module.exports = class App
    constructor : (app,@configs)->
        _ = @
        EventEmitter = require('eventemitter2').EventEmitter2
        @_event = new EventEmitter(
            wildcard:true
        )
        @_event.on('*',(infos)->
            console.log this.event
            console.log infos
        )

        #!TODO move this function to access...
        @_event.once('token/new',(datas)->
            console.log "Check INIT ROOT ?"
            try
                _.stores.group.findGroupByName('root',()->)
            catch e
                if e == 'Not found'
                    try
                        _.stores.group.addGroup('_root',(groupId)->
                            _.stores.group.addUserToGroup(datas.userId,groupId,(res)->
                                if !res
                                    throw "Error root access granted..."
                                _.stores.group.addUserToGroupCache(datas.userId,groupId,(res)->
                                    if !res
                                        throw "Error root access granted..."
                                    _.emit('root/new',datas)
                                )
                            )
                        )
                    catch e
                        console.log "ROOT INIT ERROR"
                        console.log e
                else
                    throw e
            
        )
        #@log = @app.log
        @app = app
        @app[ "auth" or @configs.bind] = @ #App binding

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
        console.log "EMIT ?"
        @event.emit(args...)
    on : (args...)->
        @event.on(args...)
