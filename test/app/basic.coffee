should = require('chai').should()
expect = require('chai').expect()
tobi = require 'tobi'

###
# Here we test the service for a basic app creation an use.
###
describe('Basic App', ()->

    app = {}

    app = {}
    browser = {}
    tool = require '../tool'

    before(()->
        app = tool.app()
        tobi.Browser.browsers = {}
        browser = tobi.createBrowser(3001, 'local.host')
        browser.userAgent = 'Mozilla/5.0 (X11; Linux i686) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.100 Safari/534.30'
    )

    after(()->
        app.express.close()
    )

    rootToken = ""
    describe('Login Root', ()->
        it('First user should be root',(done)->
            browser.get('/login/',(res, $)->
                $('form').fill(
                    email : 'root'
                    password : 'root'
                ).submit((res,$)->
                    should.exist(res.body.token)
                    rootToken = res.body.token
                    setTimeout(()->
                        done()
                    50)
                )
            )
        )
        it('Root create an application (ie. a user with some rights) and get a token',(done)->
            console.log "token #{rootToken}"
            browser.post('/user/'+rootToken,
                {
                    body : "content="+JSON.stringify(
                        login : 'myNewApp'
                    )
                },
                (res, $)->
                    should.exist(res.body.id)
                    userId = res.body.id
                    browser.post('/user/'+rootToken,
                        {
                            body : "content="+JSON.stringify(
                                login : 'myNewApp'
                            )
                        },
                        (res, $)->
                            console.log "RESULTATL : "
                            console.log res.body
                            userId = res.body.id
                            done()
                    )
            )
        )
    )
)
