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

