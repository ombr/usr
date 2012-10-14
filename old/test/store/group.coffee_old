should = require('chai').should()

describe('Store Group', ()->

    users = ['user0', 'user1', 'user2'] #!TODO Get User from a real store
    testStore = (path,configs)->
        describe(path,()->
            store = {}
            describe('constructor', ()->
                it('Can be instantiated with configs',(done)->
                    Store = require path
                    store = new Store(configs)
                    done()
                )
            )
            describe('addGroup', ()->
                it('Should be able to add a group',(done)->
                    store.addGroup('group1',(err,id)->
                        should.exist(id)
                        done()
                    )
                )
            )

            describe('getGroup', ()->
                it('Should be able to add and retrieve a group',(done)->
                    store.addGroup('group2',(err,id)->
                        should.exist(id)
                        store.getGroup(id,(err,res)->
                            res.name.should.eql('group2')
                            done()
                        )
                    )
                )
            )
            describe('findGroupByName', ()->
                it('Should be able to find an existing group',(done)->
                    store.addGroup('group_name',(err,id)->
                        should.exist(id)
                        store.findGroupByName('group_name',(err,res)->
                            res.name.should.eql('group_name')
                            done()
                        )
                    )
                )
            )
            describe('deleteGroup', ()->
                it('Should be able to delete an existing group',(done)->
                    store.addGroup('group_delete',(err,id)->
                        should.exist(id)
                        store.deleteGroup(id,(err,res)->
                            res.should.be.true
                            done()
                        )
                    )
                )
                it('Should not be able to delete a non-existent group',(done)->
                    store.addGroup('group_delete',(err,id)->
                        should.exist(id)
                        store.deleteGroup(id,(err,res)->
                            res.should.be.true
                            try
                                store.deleteGroup(id,(err,res)->
                                    trow "Callback should not be called"
                                )
                            catch err
                                done()
                        )
                    )
                )
            )

            describe('addUserToGroup', ()->

                it('Should be able to add a user',(done)->
                    store.addGroup('group_test',(err,groupId)->
                        should.exist(groupId)
                        store.addUserToGroup(users[0],groupId,(err,res)->
                            res.should.be.true
                            done()
                        )
                    )
                )
                it('Should not be able to add a user who is already in the group',(done)->
                    store.findGroupByName('group_test',(err,group)->
                        should.exist(group)
                        should.exist(group.id)
                        groupId = group.id
                        try
                            store.addUserToGroup(users[0],groupId,(err,res)->
                                throw "Callback should not be called"
                            )
                        catch e
                            done()
                    )
                )

                it('Should not be able to add a other user who is not in the group',(done)->
                    store.findGroupByName('group_test',(err,group)->
                        should.exist(group)
                        should.exist(group.id)
                        groupId = group.id
                        store.addUserToGroup(users[1],groupId,(err,res)->
                            res.should.be.true
                            done()
                        )
                    )
                )
            )


            describe('removeUserFromGroup', ()->

                it('Should be able to remove a user',(done)->
                    store.addGroup('group3',(err,groupId)->
                        should.exist(groupId)
                        store.addUserToGroup(users[0],groupId,(err,res)->
                            res.should.be.true
                            store.removeUserFromGroup(users[0],groupId,(err,res)->
                                res.should.be.true
                                store.addUserToGroup(users[0],groupId,(err,res)->
                                    res.should.be.true
                                    done()
                                )
                            )
                        )
                    )
                )

                it('Should not be able to remove user who is not in the group',(done)->
                    store.addGroup('group4',(err,groupId)->
                        should.exist(groupId)
                        store.addUserToGroup(users[0],groupId,(err,res)->
                            res.should.be.true
                            store.removeUserFromGroup(users[0],groupId,(err,res)->
                                res.should.be.true
                                try
                                    store.removeUserFromGroup(users[0],groupId,(err,res)->
                                        throw "Callback should not be called"
                                        res.should.be.true
                                    )
                                catch e
                                    done()
                            )
                        )
                    )
                )
            )

            describe('addUserToGroupCache ',()->
                it('')
            )
            describe('removeUserFromGroupCache ',()->
                it('')
            )
            describe('isUserMemberOfGroup ',()->
                it('should return true if the user is directly in the group',(done)->
                    store.addGroup('group5',(err,groupId)->
                        should.exist(groupId)
                        store.isUserMemberOfGroup(users[0],groupId,(err,res)->
                            res.should.be.false
                            store.addUserToGroup(users[0],groupId,(err,res)->
                                res.should.be.true
                                store.isUserMemberOfGroup(users[0],groupId,(err,res)->
                                    res.should.be.true
                                    store.removeUserFromGroup(users[0],groupId,(err,res)->
                                        res.should.be.true
                                        store.isUserMemberOfGroup(users[0],groupId,(err,res)->
                                            res.should.be.false
                                            done()
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
            describe('isUserMemberOfGroupCache ',()->
                it('')
            )
            describe('addGroupToGroup ',()->
                it('')
            )
            describe('addGroupToGroupCache ',()->
                it('')
            )
            describe('removeGroupToGroup ',()->
                it('')
            )
            describe('removeGroupToGroupCache ',()->
                it('')
            )
            describe('getGroupsUserIsMemberOf ',()->
                it('should return an array with all the groups the user is member',(done)->
                    store.getGroupsUserIsMemberOf(users[2],(err,groups)->
                        groups.length.should.eql(0)
                        store.addGroup('group5',(err,groupId)->
                            store.addUserToGroup(users[2],groupId,(err,res)->
                                res.should.be.true
                                store.getGroupsUserIsMemberOf(users[2],(err,groups)->
                                    groups.length.should.eql(1)
                                    groups[0].name.should.eql('group5')
                                    store.removeUserFromGroup(users[2],groupId,(err,res)->
                                        res.should.be.true
                                        store.getGroupsUserIsMemberOf(users[2],(err,groups)->
                                            groups.length.should.eql(0)
                                            done()
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
            describe('getGroupsUserIsMemberOfCache ',()->
                it('')
            )
            describe('getGroupsGroupIsMemberOf ',()->
                it('')
            )
            describe('getGroupsGroupIsMemberOfCache ',()->
                it('')
            )

        )
    for i in ['../../lib/store/local/group']
        testStore(i,null)
)
