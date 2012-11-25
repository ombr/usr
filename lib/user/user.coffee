Q = require 'q'

module.exports = class User
  me:(req,res,next)->
    _ = @
    usr = _.deps.usr
    token = req.param 'access_token'
    if !token?
      return res.json("Access token required")
    Q.all([
      usr.module('store/oauth2/token'),
      usr.module('store/user')
    ]).then((stores)->
      [tokens,users] = stores
      tokens.get(token).then((datas)->
        console.log "TOKEN"
        console.log datas
        users.get(datas.user_id)
      )
    ).then((user)->
      res.json(user)
    ).fail((error)->
      console.log "USER>ME>ERROR"
      console.log error
      res.json "Error"
    )
  init : (@deps)->
    return Q.when(true)



###
Component = require '../component'
module.exports = class User extends Component
  constructor : (app)->
    @app = app
    @store = app.stores.token
    @._routes()

  _routes : ()->
    _ = @
    #!TODO change this route...
    @routePost('/user/:token', (req, res)->
      #SECURITY : You can only check your own token
      _.add(req.login, req.params.token, (err,userId)->
        _.checkErr(err)
        res.json(id:userId)

      )
    )

    @routePost('/user/groups:token', (req, res)->
      #SECURITY : You can only check your own token
      _.add(req.groups, req.params.token, (err,res)->
        _.checkErr(err)
        res.json(res)
      )
    )

  get : (token, cb)->
    @store.getToken(token, cb)
  add : (login, token, cb)->
    _ = @
    #!TODO check login with regexp
    @app.access.check(token,['_user_add','_root'], (err,userId)->
      _.checkErr(err)
      _.app.auth.addUser(login,'local', {}, cb)
    ,'user/add')

  #This is a shortcut to create a group and put the user in it...
  addGroup : (userId, groupNames, token, cb)->
    _ = @
    @app.addGroup(groupName, token, (err,groupId)->
      @app.addUserToGroup(userId, groupId, token, cb)
    )

  #!TODO Improve perf +  Maybe merge with add Group ?
  addGroups : (userId, groupNames, token, cb)->
    _ = @
    groupAdds = []
    groupAdd = (userId, groupName, token)->
      return (cb)->
        _.addGroup(userId,groupName, token,cb)
    for groupName in groupNames
      groupAdds.push(groupAdd(userId,groupName,token))
    require('async').parallel(
      groupAdds,
      (err,res)->
        _.checkErr(err)
        cb(res)
    )
###
