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
        app.auth.addUser('local','ombr0',{},(err,userId)->
            users.push(userId)
            console.log "IDI :"
            console.log userId
            app.token.add(userId,{},(err,token)->
                tokens.push(token)
                console.log "I have a token :-D Hope I'm root ?"
                done()
            )
        )
    )

    after(()->
        app.express.close()
    )

    describe('Root user', ()->
        it('First user should be root',(done)->
            console.log tokens[0]
            app.access.check(tokens[0], ['_root'],(err,userId)->
                userId.should.eql(users[0])
                done()
            ,'test/root')
        )
        it('Second user should not be root',(done)->
            app.auth.addUser('local','ombr1',{},(err,userId)->
                users.push(userId)
                app.token.add(userId,{},(err,token)->
                    tokens.push(token)
                    app.access.check(token, ['_root'],(err,userId)->
                        err[0].should.eql('Access denied')
                        done()
                    ,'test/root')
                )
            )
        )
    )
)
