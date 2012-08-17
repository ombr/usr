#!TODO Will need change groupId to a good name
module.exports = class Store
    #Private function
    _generateId:()->
        timestamp = new Date().getTime()
        id = Math.round( timestamp+""+Math.round(Math.random()*1000))
        return id
    _addItem:(field,datas, cb)->
        if not @[field]?
            throw "INTERNAL : Field does not exists"
        id = @._generateId()
        if @[field][id]?
            throw "INTERNAL : Id collision"
        datas.id = id
        @[field][id] = datas
        cb(null,id)

    _getItem:(field,id, cb)->
        if not @[field]?
            throw "INTERNAL : Field does not exists"
        if not @[field][id]?
            cb(['Not found'],null)
            return
        cb(null,@[field][id])

    _deleteItem:(field,id, cb)->
        if not @[field]?
            throw "INTERNAL : Field does not exists"
        if not @[field][id]?
            cb(['Not found'],null)
            return
        delete(@[field][id])
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
    _empty : (field)->
        @[field] = []
