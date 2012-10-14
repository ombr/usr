#!TODO Will need change groupId to a good name
module.exports = class Store
    constructor : (@configs)->
        _ = @
        @db = new require("node-promise").Promise()
        Mongo.connect(@configs.mongoUrl,(err,conn)->
            if err?
                _.log.error err
                return
            db =
                conn :conn
            loadCollection = (collectionName,db,cb)->
                conn.collection(collectionName,(err,col)->
                    if err?
                        _.log.error err
                        #app.log.error "Can not load collection "+collectionName
                        return
                    db[collectionName] = col
                    cb()
                )
            require('async').parallel([
                (cb)->
                    loadCollection('users',db,cb)
                ,(cb)->
                    loadCollection('groups',db,cb)
                ,(cb)->
                    loadCollection('tokens',db,cb)
                ],()->
                    _.db.resolve(db)
            )
        )
    #Private function
    _error:(err)->
        if err != null
            throw err #!TODO improve this function...
    _addItem:(field,datas, cb)->
        _ = @
        @db.then((db)->
            if not db[field]?
                throw "INTERNAL : Collection #{field} does not exists"
            db[field].insert(datas,(err,datas)->
                _._error(err)
                datas[0].id = datas[0]._id
                cb(null,datas[0].id)
            )
        )

    _getItem:(field, id, cb)->
        _ = @
        oid = null
        try
            ObjectID = require('mongodb').ObjectID
            oid = new ObjectID(String(id))
        catch e
            console.log "ERROR MONGO DB ID CONVERSION..."
            cb(['Not found'], null)
            return
        @db.then((db)->
            if not db[field]?
                throw "INTERNAL : Collection #{field} does not exists"

            db[field].findOne({"_id":oid},{},(err,datas)->
                _._error(err)
                datas.id = datas._id
                delete(datas._id)
                if datas == null
                    cb(['Not found'],null)
                    return
                cb(null,datas)
            )
        )
    _deleteItem:(field,id, cb)->
        throw "Not yet implemented..."
        cb(null,true)

    _findOneItemBy : (field, fieldToSearch, value, cb)->
        if not @[field]?
            throw "INTERNAL : Field does not exists"
        for k, v of @[field]
            if v[fieldToSearch]?
                if v[fieldToSearch] == value
                    cb(null,v)
                    return
        cb(['Not found'],null)
        return

    _addItemToItemField : (groupId, field, item,cb)->
        if not @_groups[groupId]?
            cb(['Group does not exists'],null)
            return
        if not @_groups[groupId][field]?
            throw "INTERNAL : Field does not exists"
        if item in @_groups[groupId][field]
            cb(['Item already in field'],null)
            return
        @_groups[groupId][field].push(item)
        cb(null,true)

    _isItemInItemField : (groupId,field, item, cb)->
        if not @_groups[groupId]?
            cb(['Group does not exists'],null)
            return
        if not @_groups[groupId][field]?
            throw "INTERNAL : Field does not exists"
        if item in @_groups[groupId][field]
            cb(null,true)
            return
        cb(null,false)

    _getItemsWhereItemIsInField : (field, item, cb)->
        res = []
        for k,v of @_groups
            if v[field]?
                if item in v[field]
                    res.push(v)
        cb(null,res)

    _removeItemFromItemField : (groupId, field, item,cb)->
        if not @_groups[groupId]?
            cb(['Group does not exists'],null)
            return
        if not @_groups[groupId][field]?
            throw "INTERNAL : Field does not exists"
        if not item in @_groups[groupId][field]
            cb(['Item not in field'],null)
            return

        index = @_groups[groupId][field].indexOf(item)
        if index == -1
            cb(null,false)
            return
        @_groups[groupId][field].splice(index, 1)
        cb(null,true)
