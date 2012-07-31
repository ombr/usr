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
        cb(id)

    _getItem:(field,id, cb)->
        if not @[field]?
            throw "INTERNAL : Field does not exists"
        if not @[field][id]?
            throw "Not found"
        cb(@[field][id])

    _deleteItem:(field,id, cb)->
        if not @[field]?
            throw "INTERNAL : Field does not exists"
        if not @[field][id]?
            throw "Not found"
        delete(@[field][id])
        cb(true)

    _findOneItemBy : (field, fieldToSearch, value, cb)->
        if not @[field]?
            throw "INTERNAL : Field does not exists"
        for k, v of @[field]
            if v[fieldToSearch]?
                if v[fieldToSearch] == value
                    cb(v)
                    return
        throw "Not found"

    _addItemToItemField : (groupId, field, item,cb)->
        if not @_groups[groupId]?
            throw "Group does not exists"
        if not @_groups[groupId][field]?
            throw "INTERNAL : Field does not exists"
        if item in @_groups[groupId][field]
            throw "Item already in field"
        @_groups[groupId][field].push(item)
        cb(true)

    _isItemInItemField : (groupId,field, item, cb)->
        if not @_groups[groupId]?
            throw "Group does not exists"
        if not @_groups[groupId][field]?
            throw "INTERNAL : Field does not exists"
        if item in @_groups[groupId][field]
            cb(true)
            return
        cb(false)

    _getItemsWhereItemIsInField : (field, item, cb)->
        res = []
        for k,v of @_groups
            if v[field]?
                if item in v[field]
                    res.push(v)
        cb(res)

    _removeItemFromItemField : (groupId, field, item,cb)->
        if not @_groups[groupId]?
            throw "Group does not exists"
        if not @_groups[groupId][field]?
            throw "INTERNAL : Field does not exists"
        if not item in @_groups[groupId][field]
            throw "Item not in field"
        index = @_groups[groupId][field].indexOf(item)
        if index == -1
            cb(false)
            return
        @_groups[groupId][field].splice(index, 1)
        cb(true)
