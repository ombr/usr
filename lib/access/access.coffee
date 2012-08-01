Component = require '../component'
module.exports = class Access extends Component
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
        _ = @
        return (cb)->
            try
                _.app.stores.group.findGroupByName(groupName, (group)->
                    _.app.stores.group.isUserMemberOfGroupCache(userId, group.id,(res)->
                        cb(null, res)
                    )
                )
            catch e
                if e == 'Not found'
                    cb(null, false)
                    return
                throw e

    #!TODO improve this function with cache 
    _checkToken: (token, callbackOK)->
        try
            @token.getToken(token, (datas)->
                #!TODO Token read only ?
                #!TODO Token time expiration
                if datas.userId?
                    console.log "TOKEN OK"
                    callbackOK(datas.userId)
            )
        catch e
            throw e
    
    check : (token, groups, cb, action = "undefined") ->
        _ = @
        @_checkToken(token,
            (userId)->
                groupCheck = []
                for g in groups
                    groupCheck.push(_._isUserMemberOfGroup(userId, g))
                try
                    require('async').parallel(groupCheck,(err,res)->
                        if true in res
                            cb(userId)
                            _.emit('access/'+action,
                                granted : true
                                token : token
                                userId : userId
                                groups : groups
                            )
                            return
                        _.emit('access/'+action,
                            granted : false
                            token : token
                            userId : userId
                            groups : groups
                        )
                        throw 'Access denied'
                        return
                    )
                catch e
                    console.log "ERROR IN CHECK ?#{e}?"
                    console.log e
                    throw e
            )
    _add : (groupName, token, cb)->
        _ = @
        #!TODO check group existence
        @store.addGroup(groupName, (res)->
            cb(res)
            _.event.emit('group:new',groupId, token)
        )

    #This function should be in group....
    add : (groupName, token, cb)->
        _ = @
        @access.check(token, ['_group_add','root'],()->
            _._add(groupName,cb)
        ,'group/add')
    ###
