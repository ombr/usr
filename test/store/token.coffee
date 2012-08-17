should = require('chai').should()
describe('Store Token',()->
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

            describe('addToken',()->
                it('Should be able to add a token',(done)->
                    store.addToken(
                        content: 'lalal'
                        plus : 'yeass'
                    ,(err,token)->
                        should.not.exist(err)
                        should.exist(token)
                        done()
                    )
                )
                it('Should be able to retreive the token',(done)->
                    obj =
                        content: 'lalala',
                        test: 'yes',
                        lalal:
                            lala:12
                            difficult: 'Oui !'
                    store.addToken(
                        obj,
                        (err,token)->
                            store.getToken(token,(err,datas)->
                                should.not.exist(err)
                                datas.should.eql(obj)
                                done()
                            )
                    )
                )
            )
            describe('getToken',()->
                it('Should be able to get a token',(done)->
                    obj =
                        content: 'lalala',
                        test: 'yes 2',
                        lalal:
                            lala:12
                            difficult: 'Oui !'
                    store.addToken(
                        obj,
                        (err,token)->
                            store.getToken(token,(err,datas)->
                                should.not.exist(err)
                                datas.should.eql(obj)
                                done()
                            )
                    )
                )
                
                it('Should not be able to get a token which does not exists',(done)->
                    obj =
                        content: 'lalala',
                        test: 'yes 2',
                        lalal:
                            lala:12
                            difficult: 'Oui !'
                    store.addToken(
                        obj,
                        (err,token)->
                            store.getToken(token,(err,datas)->
                                datas.should.eql(obj)
                                store.deleteToken(token,(err,res)->
                                    res.should.be.true
                                    store.getToken(token,(err,datas)->
                                        err[0].should.eql('Not found')
                                        should.not.exist(datas)
                                        done()
                                    )
                                )
                            )
                    )
                )
            )
            describe('deleteToken',()->
                it('Should be able to delete a token',(done)->
                    obj =
                        content: 'lalala',
                        test: 'yes 2',
                        lalal:
                            lala:12
                            difficult: 'Oui !'
                    store.addToken(
                        obj,
                        (err,token)->
                            store.getToken(token,(err,datas)->
                                datas.should.eql(obj)
                                store.deleteToken(token,(err,res)->
                                    res.should.be.true
                                    store.getToken(token,(err,datas)->
                                        err[0].should.eql('Not found')
                                        should.not.exist(datas)
                                        done()
                                    )
                                )
                            )
                    )
                )
                it('Should not be able to delete a token which does not exists',(done)->
                    obj =
                        content: 'lalala',
                        test: 'yes 2',
                        lalal:
                            lala:12
                            difficult: 'Oui !'
                    store.addToken(
                        obj,
                        (err,token)->
                            store.getToken(token,(err,datas)->
                                datas.should.eql(obj)
                                store.deleteToken(token,(err,res)->
                                    res.should.be.true
                                    store.getToken(token,(err,datas)->
                                        should.not.exist(datas)
                                        store.deleteToken(token,(err,res)->
                                            should.not.exist(err)
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
    for i in ['../../lib/store/local/token']
        testStore(i,null)
)
