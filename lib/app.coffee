module.exports = class App
    constructor : (express,@configs)->
        _ = @
        if not @configs.logger?
            Log = require 'log'
            @log = new Log("warning")
        else
            @log = @configs.logger

        EventEmitter = require('eventemitter2').EventEmitter2
        @_event = new EventEmitter(
            wildcard:true
        )
        @_event.on('*',(infos)->
            _.log.debug "EVENT #{@event} : #{JSON.stringify(infos)}"
        )

        #!TODO move this function to access...
        @_event.once('token/new',(datas)->
            _.log.debug "First token has been created maybe a root group need to be created ?"
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
                            _.stores.group.addUserToGroupCache(datas.userId,groupId,(err,res)->
                                if !res
                                    throw "Error root access granted..."
                                # Might be a bit strange, but root seems to proclam himself root
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
