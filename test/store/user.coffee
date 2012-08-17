should = require('chai').should()

describe('Store User', ()->

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
            describe('Users', ()->
                describe('addUser', ()->
                    it('Should be able to add a user and get a uniq id for the user',(done)->
                        store.addUser('local','user1',
                            login:'user1'
                            password: 'superpassword'
                            ,(err,userId)->
                                should.not.exist(err)
                                should.exist(userId)
                                done()
                        )
                    )
                )

                describe('findUserId', ()->
                    it('Should not be able to retrieve a non existing user',(done)->
                        store.findUserById(Math.round(Math.random()*100000),(err,userId)->
                                should.exist(err)
                                should.not.exist(userId)
                                done()
                        )
                    )
                    it('Should be able to retrieve an existing user',(done)->
                        store.addUser('local','user3',
                            login:'user3'
                            password: 'superpassword'
                            ,(err,userId)->
                                store.findUserById(userId,(err,user)->
                                    should.not.exist(err)
                                    should.exist(user)
                                    should.exist(user.id)
                                    user['local'].login.should.eql('user3')
                                    user['local'].password.should.eql('superpassword')
                                    done()
                                )
                        )
                    )
                )
                describe('findUserBySourceAndId', ()->
                    it('Should not be able to retrieve a non existing user',(done)->
                            store.findUserBySourceAndId('local','nonuser',(err,user)->
                                should.exist(err)
                                should.not.exist(user)
                                done()
                            )
                    )
                    it('Should be able to retrieve an existing user',(done)->
                        store.addUser('local','user2',
                            login:'user2'
                            password: 'superpassword'
                            ,(err,user)->
                                store.findUserBySourceAndId('local','user2',(err,user)->
                                    should.not.exist(err)
                                    should.exist(user)
                                    user.local.login.should.equal('user2')
                                    user.local.password.should.equal('superpassword')
                                    should.exist(user.id)
                                    done()
                                )
                        )
                    )
                )
            )
        )
            
    for i in ['../../lib/store/local/user']
        testStore(i,null)
)
