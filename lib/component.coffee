module.exports = class Component
    constructor : (app)->
        @app = app

    request : (func,cb)->
        try
            func(req,res)
            if cb?
                cb(req,res)
        catch e
            res.json(e)

    ###
    #   Helpers used in all application
    ###
    error : (req,res)->
        res.json(
            error:true
        )
    #!TODO Make a better check error
    checkErr : (err)->
        if err != null
            throw new Error(err)
        
    ###
    #   Express route encapsulation
    ###
    routeGet : (args...)->
        @express().get(args...)
    routePost : (args...)->
        @express().post(args...)
    routeUpdate : (args...)->
        @express().update(args...)
    routeDelete : (args...)->
        @express().delete(args...)

    ###
    #   Events
    ###
    emit : (args...)->
        @app._event.emit(args...)
    on : (args...)->
        @app._event.on(args...)

    log : ()->
        return @app.log
    express : ()->
        return @app.express
