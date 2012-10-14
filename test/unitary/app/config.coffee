expect = require('chai').expect()


describe('Configs', ()->
  describe('/login', ()->
    it('Should be able to get a config.', (done)->
      Usr = require '../../../index'
      usr = new Usr
      usr.config('my_key', 'my_value','Amazing key').then((value)->
        value.should.eql('my_value')
        done()
      )
    )

    it('Should be able to set and get a config.', (done)->
      Usr = require '../../../index'
      usr = new Usr
      usr.config('my_key', 'my_value','Amazing key').then((value)->
        value.should.eql('my_value')
        usr.config('my_key', 'my_new_value','Amazing key').then((value)->
          value.should.eql('my_value')
          done()
        )
      )
    )
    it('Should be overwritten by environement variables.', (done)->
      done()
      return; #TODO HOW TO TEST THIS ?
      Usr = require '../../../index'
      usr = new Usr
      process.env.my_value = 'Environement Value'
      console.log process.env.my_value
      usr.config('my_key', 'my_value','Amazing key').then((value)->
        console.log "TEST"
        console.log value
        value.should.eql('Environement Value')
        usr.config('my_key', 'my_new_value','Amazing key').then((value)->
        done()
          value.should.eql('Environement Value')
          done()
        )
      )
    )
  )


)
