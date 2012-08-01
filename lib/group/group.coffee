
Component = require '../component'
module.exports = class Group extends Component
    constructor : (app)->
        @app = app
        @store = app.stores.group
        @event = app.event
        @access = app.access
        @._routes()

    _routes : ()->
        _ = @
        @.route_get('/group/:token', (req, res)->
            res.redirect('/not-implemented-yet')
        )

        @.route_post('/group/', (req, res)->
            _.add(
                req.params.name,
                req.params.token,
                (res)->
                    req.json(res)
            )
        )

        @.route_post('/group/:name/users/', (req, res)->
            #!TODO Get user by token ?
            userId = req.params.userId
            _.addUserToGroup(
                req.params.name,
                req.params.userId,
                (res)->
                    req.json(res)
            )
        )


    add : (groupName, token, cb)->
        _ = @
        #!TODO Validate Name with Regex
        _.app.access.check(token, ['_group_add','_root'],(userId)->
            #!TODO check group existence
            _.store.addGroup(groupName, (groupId)->
                console.log "TEST :"
                console.log cb
                cb(groupId)
                _.event.emit('group:new',
                    groupId : groupId
                    token : token
                )
            )
        )
    addUserToGroup : (groupName, userId, token, cb)->
        _ = @
        #!TODO Validate Regex
        _.app.access.check(token,
            [
                'group_'+groupName+"_"+owner,
                'group_'+groupName+"_"+add,
                '_root'
            ],
            (userId)->
                @store.findGroupByName(groupName,(group)->
                    @store.addUserToGroup(group.id,userId,cb)
                    @store.addUserToGroupCache(group.id,userId,()->
                        _.event.emit('group:addUser',
                            groupId : groupId
                            token : token
                        )
                    )
                    addUserToGroupCache = (groupId, userId)->
                        @store.addUserToGroupCache(i,userId,()->
                            _.event.emit('group:addUser',
                                groupId : groupId
                                token : token
                            )
                        )
                    for i in group._groups
                        addUserToGroupCache(i, userId)
                )
        )
