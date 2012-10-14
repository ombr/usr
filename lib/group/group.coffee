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
    @.routeGet('/group/:token', (req, res)->
      res.redirect('/not-implemented-yet')
    )

    @.routePost('/group/', (req, res)->
      _.add(
        req.params.name,
        req.params.token,
        (res)->
          req.json(res)
      )
    )

    @.routePost('/group/:name/users/', (req, res)->
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
    #!TODO Validate Name with Regex and rules
    
    #Add a new user Group
    #Add a new group access group

    #Add a new Group
    _.app.access.check(token, ['_group_add','_root'],(userId)->
      #!TODO check group existence
      _.store.addGroup(groupName, (err,groupId)->
        cb(err,groupId)
        _.emit('group:new',
          groupId : groupId
          token : token
          groupName : groupName
          authorId : userId
        )
      )
    )
  addUserToGroup : (userId, groupName, token, cb)->
    _ = @
    #!TODO Validate Regex
    _.app.access.check(token,
      [
        'group_'+groupName+"_add",
        '_root'
      ],
      (authorId)->
        _.store.findGroupByName(groupName,(err,group)->
          _.checkErr(err)
          _.store.addUserToGroup(userId,group.id,cb)
          _.emit('group:addUser',
            groupId : group.id
            token : token
            authorId : authorId
            userId : userId
            groupName : groupName
          )
          #Add to cache
          addUserToGroupCache = (groupId, userId)->
            _.store.addUserToGroupCache(userId, groupId,(err,res)->
              _.checkErr(err)
              _.emit('group:addUserCache',
                groupId : group.id
                token : token
                userId : userId
                groupName : groupName
              )
            )
          addUserToGroupCache(group.id, userId)
          for i in group._groups
            addUserToGroupCache(i, userId)
        )
    )
