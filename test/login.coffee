should = require('chai').should()
expect = require('chai').expect()

describe('Login Logout', ()->

    app = {}

    app = {}
    browser = {}
    tool = require './tool'

    before(()->
        app = tool.app()
        console.log app.stores
        browser = tool.browser()
    )

    after(()->
        tool.delete(app)
    )

    describe('/login', ()->
        it('A user should be able to get a valid token',(done)->
            browser.get('/login/',(res, $)->
                $('form').fill(
                    email : 'ombr'
                    password : 'ombr'
                ).submit((res,$)->
                    should.exist(res.body.token)
                    browser.get('/token/'+res.body.token+"/"+res.body.token,(res,$)->
                        res.body.local.login.should.eql('ombr')
                        done()
                    )
                )
            )
        )
        it('A user should be able to delete a token he owns')

        it('A user should be able to logout and login again',(done)->
            browser.get('/logout',(res, $)->
                browser.get('/login/',(res, $)->
                    $('form').fill(
                        email : 'ombr'
                        password : 'ombr'
                    ).submit((res,$)->
                        browser.get('/token/'+res.body.token+"/"+res.body.token,(res,$)->
                            res.body.local.login.should.eql('ombr')
                            done()
                        )
                    )
                )
            )
        )

        it('A user should not be able to login with a wrong password',(done)->
            browser.get('/logout',(res, $)->
                browser.get('/login/',(res, $)->
                    $('form').fill(
                        email : 'ombr'
                        password : 'ombr_wrong'
                    ).submit((res,$)->
                        $('#errors').text().should.eql('Wrong Password')
                        done()
                    )
                )
            )
        )
    )

    describe('/me', ()->
        it('A user should be able to get informations about himself')
    )
)
