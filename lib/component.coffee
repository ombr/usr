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
    ###
    #   Express route encapsulation
    ###
    route_get : (args...)->
        @app.app.get(args...)
    route_post : (args...)->
        @app.app.post(args...)
    route_update : (args...)->
        @app.app.update(args...)
    route_delete : (args...)->
        @app.app.delete(args...)

    ###
    #   Events
    ###
    emit : (args...)->
        @app._event.emit(args...)
    on : (args...)->
        @app._event.on(args...)
