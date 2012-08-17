should = require('chai').should()
expect = require('chai').expect()
tobi = require 'tobi'

describe('Token GetInfo', ()->


    app = {}
    tool = require '../tool'

    before(()->
        app = tool.app()
    )

    after(()->
        app.express.close()
    )

    rootToken = null
    rootId = null
    it('Root user should be able to get Info',(done)->
        tool.user(app, (userId)->
            rootId = userId
            tool.token(app,userId, (token)->
                rootToken = token
                setTimeout(()-> #Timeout required for event propagation
                    app.token.getInfo(token,token,(err,infos)->
                        should.not.exist(err)
                        should.exist(infos)
                        infos.id.should.eql rootId
                        should.exist(infos.groups)
                        infos.groups.should.contain "_root"
                        done()
                    )
                ,5)
            )
        )
    )
)
