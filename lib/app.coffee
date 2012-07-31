EventEmitter = require('events').EventEmitter

module.exports = class App
    constructor : (app,@configs)->
        @event = new EventEmitter #Maybe we will want to have an external object fot that...
        #@log = @app.log
        @app = app
        @app[ "auth" or @configs.bind] = @ #App binding

        #Init stores :
        @stores = {}
        for store,configs of @configs.stores
            StoreClass = require '../'+configs.class
            @stores[store] = new StoreClass(configs.configs)
        #!TODO Check If stores are OK (user, token, group)

        #Init authentification
        Auth = require './auth'
        auth = new Auth(@)
    ###
    #   Helpers used in all application
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


