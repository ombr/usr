should = require('chai').should()
expect = require('chai').expect()
tobi = require 'tobi'

describe('Root Capabilities', ()->


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
    it('First user should be root',(done)->
        tool.user(app, (userId)->
            rootiId = userId
            tool.token(app,userId, (token)->
                rootToken = token
                setTimeout(()-> #Timeout required for event propagation
                    app.access.check(token, ['_root'],(err,rootId)->
                        rootId.should.eql(userId)
                        done()
                    ,'test/root')
                ,5)
            )
        )
    )
    it('Second user should not be root',(done)->
        tool.user(app, (userId)->
            tool.token(app,userId, (token)->
                setTimeout(()-> #Timeout required for event propagation
                    app.access.check(token, ['_root'],(err,rootId)->
                        should.exist(err)
                        should.exist(err[0])
                        err[0].should.eql('Access denied')
                        done()
                    ,'test/root')
                ,5)
            )
        )
    )
    it('Should be able to create a group and put himself in it',(done)->
        groupName = tool._uniq('group')
        app.group.add(groupName,rootToken,(err,groupId)->
            app.group.addUserToGroup(rootId,groupName,rootToken,(err,res)->
                res.should.be.true
                should.not.exist(err)
                done()
            )
        )
    )
)
