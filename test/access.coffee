should = require('chai').should()
expect = require('chai').expect()
tobi = require 'tobi'

describe('Access', ()->

    app = {}
    browser = {}
    users = []
    groups = []
    tokens = []
    before((done)->
        app = require('./app')()
        tobi.Browser.browsers = {}
        browser = tobi.createBrowser(3001, 'local.host')
        browser.userAgent = 'Mozilla/5.0 (X11; Linux i686) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.100 Safari/534.30'
        app.auth.addUser('local','ombr0',{},(userId)->
            users.push(userId)
            console.log "IDI :"
            console.log app.token.add
            app.token.add(userId,{},(token)->
                tokens.push(token)
                console.log "I have a token :-D Hope I'm root ?"
                done()
                return
                setTimeout(()->
                    console.log app.stores.group._groups
                    app.auth.addUser('local','ombr1',{},(userId)->
                        users.push(userId)
                        app.auth.addUser('local','ombr2',{},(userId)->
                            users.push(userId)
                            app.group.add('group0',token, (groupId)->
                                groups.push(groupId)
                                app.group.add('group1',token, (groupId)->
                                    groups.push(groupId)
                                    app.group.add('group2',token, (groupId)->
                                        groups.push(groupId)
                                        app.group.add('group3',token, (groupId)->
                                            groups.push(groupId)
                                            done()
                                        )
                                    )
                                )
                            )
                        )
                    )
                ,500)
            )
        )
    )

    after(()->
        app.app.close()
    )

    describe('Root user', ()->
        it('First user should be root',(done)->
            app.access.check(tokens[0], ['_root'],(userId)->
                userId.should.eql(users[0])
                done()
            ,'test/root')
        )
        it('Second user should not be root',(done)->
            app.auth.addUser('local','ombr1',{},(userId)->
                users.push(userId)
                app.token.add(userId,{},(token)->
                    tokens.push(token)
                    try
                        app.access.check(token, ['_root'],(userId)->
                            throw "Callback should not be called"
                        ,'test/root')
                    catch e
                        e.should.eql('Access denied')
                        done()
                )
            )
        )
    )
)
