chai      = require('chai')
sinon     = require('sinon')
sinonChai = require('sinon-chai')
expect    = chai.expect

chai.use sinonChai

SessionDescriptionCreator = require('../../private/session-description-creator.js')

describe 'SessionDescriptionCreator', ->
  beforeEach ->
    @observatory    = new Object
    @peerId         = 'an peer id'
    @peerConnection =
      createOffer: ->

    @creator = new SessionDescriptionCreator(
      @observatory, @peerId, @peerConnection
    )

  afterEach ->
    sinon.collection.restore()

  describe '#forOffer', ->
    it 'creates an offer on the peer connection', ->
      failureCallback = @creator.failureCallback
      sinon.collection.stub(@creator, 'successCallback').
        withArgs(@creator.sendOffer).
        returns successCallback = new Object
      createOffer = sinon.collection.stub @peerConnection, 'createOffer'

      @creator.forOffer()

      expect(createOffer).to.have.been.calledWith successCallback, failureCallback
