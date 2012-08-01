Store = require './store'
module.exports = class Group extends Store
    constructor : ()->
        @_groups = {}

    addGroup : (groupName, cb)->
        @_addItem("_groups",
            {
                name : groupName,
                users : []
                groups : []
                _users : []
                _groups : []
            }
            ,cb
        )

    getGroup : (groupId, cb)->
        @_getItem('_groups',groupId,cb)

    deleteGroup : (groupId,cb)->
        @_deleteItem('_groups',groupId,cb)

    findGroupByName : (name,cb)->
        @_findOneItemBy('_groups','name',name, cb)

    addUserToGroup : (userId, groupId, cb)->
        @_addItemToItemField(groupId, 'users',userId,cb)
    
    removeUserFromGroup : (userId,groupId, cb)->
        @_removeItemFromItemField(groupId, 'users', userId, cb)

    addUserToGroupCache : (userId,groupId,cb)->
        @_addItemToItemField(groupId, '_users',userId,cb)

    removeUserFromGroupCache : (userId,groupId, cb)->
        @_removeItemFromItemField(groupId, '_users', userId, cb)

    #Note : This function will never be used maybe should be deprecated or deleted
    isUserMemberOfGroup : (userId,groupId,cb)->
        @_isItemInItemField(groupId, 'users',userId,cb)

    isUserMemberOfGroupCache : (userId,groupId,cb)->
        @_isItemInItemField(groupId, '_users',userId,cb)

    addGroupToGroup : (groupId1, groupId2, cb)->
        @_addItemToItemField(groupId1, 'groups',groupId2,cb)

    addGroupToGroupCache : (groupId1, groupId2, cb)->
        @_addItemToItemField(groupId1, '_groups',groupId2,cb)
    
    removeGroupToGroup : (groupId1, groupId2, cb)->
        @_removeItemFromItemField(groupId1, 'groups', groupId2, cb)
    
    removeGroupToGroupCache : (groupId1, groupId2, cb)->
        @_removeItemFromItemField(groupId1, '_groups', groupId2, cb)

    getGroupsUserIsMemberOf : (userId,cb)->
        @_getItemsWhereItemIsInField("users", userId, cb)

    getGroupsUserIsMemberOfCache : (userId,cb)->
        @_getItemsWhereItemIsInField("_users", userId, cb)

    getGroupsGroupIsMemberOf : (groupId, cb)->
        @_getItemsWhereItemIsInField("groups", groupId, cb)

    getGroupsGroupIsMemberOfCache : (groupgroupId, cb)->
        @_getItemsWhereItemIsInField("_groups", groupId, cb)
