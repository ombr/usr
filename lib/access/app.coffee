module.exports = class Acess
    constructor : (app)->
        @app = app
        @app.access = @
        @group = app.stores.group
        @groupCache = {}
        @token = app.stores.token
        @event = app.event
        @access = app.access

    #!TODO this function can be improve with some local cache ? Array ?
    _isUserMemberOfGroup: (userId, groupName)->
        return (cb)->
            _.groups.findGroupByName('groupName', (group)->)
            _.groups.isUserMemberOfGroupCache(datas.userId, group.id,cb)

    #!TODO improve this function with cache 
    _checkToken: (token, callbackOK, callbackKO)->
        try
            @token.getToken(token, (datas)->
                #!TODO Token read only ?
                #!TODO Token time expiration
                if datas.userId?
                    callbackOK(userId)
            )
        catch
            callbackKO(false)
    
    check : (token, groups, cb)
        _ = @
        @_checkToken(
            token,
            (userId)->
                groupCheck = []
                for g in groups
                    call.push(_._isUserMemberOfGroup(datas.userId, g))
                require('async').parallel(groupCheck,(res)->
                    if true in res
                        cb(true)
                        return
                    cb(false)
                    return
                )
            ,cb
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
        

