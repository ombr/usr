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
                _.app.stores.group.findGroupByName(groupName, (err,group)->
                    if err?
                        if err[0] == 'Not found'
                            cb(null,false)
                            return
                        else
                            cb(err,null)
                            return
                    _.app.stores.group.isUserMemberOfGroupCache(userId, group.id,(err,res)->
                        cb(null, res)
                    )
                )
    #!TODO improve this function with cache 
    _checkToken: (token, callbackOK)->
        _ = @
        @token.getToken(token, (err,datas)->
            _.checkErr(err)
            #!TODO Token read only ?
            #!TODO Token time expiration
            if datas.userId?
                callbackOK(null,datas.userId)
        )
    
    check : (token, groups, cb, action = "undefined") ->
        _ = @
        @_checkToken(token,
            (err,userId)->
                _.checkErr(err)
                groupCheck = []
                for g in groups
                    groupCheck.push(_._isUserMemberOfGroup(userId, g))
                require('async').parallel(groupCheck,(err,res)->
                    _.checkErr(err)
                    if true in res
                        cb(null,userId)
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
                    cb(['Access denied'],null)
                    return
                )
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
