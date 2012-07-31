module.exports = class App
    constructor : (app)->
        @app = app
        @store = app.stores.group
        @event = app.event
        @access = app.access

    _routes : ()->
        _ = @
        @app.get('/groups/:token', (req, res)->
            res.redirect('/not-implemented-yet')
        )

        @app.post('/groups/:token', (req, res)->
            res.redirect('/not-implemented-yet')
        )

    _add : (groupName, token, cb)->
        _ = @
        #!TODO check group existence
        @store.addGroup(groupName, (res)->
            cb(res)
            _.event.emit('group:new',groupId, token)
        )

    add : (groupName, token, cb)->
        _ = @
        @access.check(token, ['_group_add','root'],()->
            _._add(groupName,cb)
        )
        

