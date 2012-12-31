Q = require 'q'
should = require('chai').should()
describe('Groups', ()->
  describe('Create', ()->
    it('Should be created when you add a user to it')
  )
  describe('List', ()->
    it('We should be able to retrieve a list of non empty groups')
  )
  describe('List Users', ()->
    it('Should be empty if does not contains any user or does not exists')
    it('Should list all the user it contains')
  )
  describe('Add User', ()->
    it('Should be able to add a user and see it.')
  )
  describe('Remove User', ()->
    it('Should be able to remove a user')
    it('Should not be able to remove a user who is not in the group.')
  )
  describe('Contains User', ()->
    it('Should return true if it contains a user')
    it('Should return false if it does not contains a user')
  )
  describe('Empty', ()->
    it('Should be able to empty a group')
  )
)
