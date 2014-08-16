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
      createAnswer: ->

    @creator = new SessionDescriptionCreator(
      @observatory, @peerId, @peerConnection
    )

  afterEach ->
    sinon.collection.restore()

  describe 'main public behavior', ->
    beforeEach ->
      @failureCallback = @creator.failureCallback
      @stubSuccessCallback = (arg) =>
        sinon.collection.stub(@creator, 'successCallback').
          withArgs(arg).
          returns @successCallback = new Object

    describe '#forOffer', ->
      it 'creates an offer on the peer connection', ->
        @stubSuccessCallback @creator.sendOffer
        createOffer = sinon.collection.stub @peerConnection, 'createOffer'

        @creator.forOffer()

        expect(createOffer).to.have.been.calledWith @successCallback, @failureCallback

    describe '#forAnswer', ->
      it 'creates an answer on the peer connection', ->
        @stubSuccessCallback @creator.sendAnswer
        createAnswer = sinon.collection.stub @peerConnection, 'createAnswer'

        @creator.forAnswer()

        expect(createAnswer).to.have.been.calledWith @successCallback, @failureCallback
