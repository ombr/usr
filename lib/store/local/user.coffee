Store = require './store'
module.exports = class User extends Store
    constructor : (configs)->
        @_users = {}
        @_usersBySource = {}
        @_groups = {}
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
            throw 'Not found'
        if not @_usersBySource[source][id]?
            throw 'Not found'
        cb(@_usersBySource[source][id])

