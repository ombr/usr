should = require('chai').should()
expect = require('chai').expect()
tobi = require 'tobi'

describe('Login Logout', ()->

    app = {}
    browser = {}
    before(()->
        app = require('./app')()
        tobi.Browser.browsers = {}
        browser = tobi.createBrowser(3001, 'local.host')
        browser.userAgent = 'Mozilla/5.0 (X11; Linux i686) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.100 Safari/534.30'
    )

    after(()->
        app.app.close()
    )

    describe('/login', ()->
        it('A user should be able to get a valid token',(done)->
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
