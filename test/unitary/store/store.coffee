Q = require 'q'
should = require('chai').should()

describe('Store User', ()->
  testStore = (getStore)->
    describe('add', ()->
      it('Should be empty',(done)->
        getStore().then((store)->
          store.get(32432423432).fail(()->
            done()
          ).end()
        )
      )
      it('Some datas can be set and retrieve',(done)->
        getStore().then((store)->
          store.add(
            key:'lalal'
            key2:'value'
          ).then((id)->
            store.get(id)
          ).then((datas)->
            done()
          ).end()
        )
      )
    )
    describe('delete', ()->
      it('Some datas can be set delete and not retrieved',(done)->
        getStore().then((store)->
          store.add(
            key:'lalal'
            key2:'value'
          ).then((id)->
            return store.delete(id).then(()->
              store.get(id).fail(()->
                done()
              )
            )
          ).end()
        )
      )
      it('should not be able to delete twice',(done)->
        getStore().then((store)->
          store.add(
            key:'lalal'
            key2:'value'
          ).then((id)->
            return store.delete(id).then(()->
              store.delete(id).fail(()->
                done()
              )
            )
          ).end()
        )
      )
    )
    describe('findOneBy', ()->
      it('Should return a user which match',(done)->
        getStore().then((store)->
          obj =
            test: 'sdfsdf'
          store.add(
            key1:'lalal'
            key2:'value'
          ).then(()->
            return store.findOneBy(
              key1:'lalal'
            )
          ).then((res)->
            res.key2.should.equal("value")
            done()
          )
        )
      )
      it('should not be able to delete twice',(done)->
        getStore().then((store)->
          store.add(
            key:'lalal'
            key2:'value'
          ).then((id)->
            return store.delete(id).then(()->
              store.delete(id).fail(()->
                done()
              )
            )
          ).end()
        )
      )
    )
      
  for path in ['../../../lib/store/store']
    testStore(()->
      Store = require path
      store = new Store()
      return Q.when(store)
    )
)
