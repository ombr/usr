Store = require './store'
module.exports = class User extends Store
    constructor : (configs)->
        @_users = {}
        @_usersBySource = {}
    addUser : (source, id, datas,cb)->
        user = {}
        datas.id = id
        user[source] = datas

        if not @_usersBySource[source]?
            @_usersBySource[source] = {}
        @_usersBySource[source][id] = user
        @_addItem("_users", user, cb)

    findUserById : (id,cb)->
        @_getItem("_users", id, cb)

    findUserBySourceAndId : (source, id, cb)->
        if not @_usersBySource[source]?
            cb(['Not found'],null)
            return
        if not @_usersBySource[source][id]?
            cb(['Not found'],null)
            return
        cb(null,@_usersBySource[source][id])
    empty : (cb)->
        @_empty('_users')
        @_empty('_usersBySource')
        cb(null,true)
