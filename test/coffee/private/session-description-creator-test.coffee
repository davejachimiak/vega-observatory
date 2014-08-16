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
      setLocalDescription: ->

    @creator = new SessionDescriptionCreator(
      @observatory, @peerId, @peerConnection
    )
    @failureCallback = @creator.failureCallback

  afterEach ->
    sinon.collection.restore()

  describe 'main public behavior', ->
    beforeEach ->
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

  describe 'successCallback', ->
    it 'returns a callback that sets a local description with proper args', ->
      onLocalDescriptionSuccess = ->
      description = 'description'
      setLocalDescription =
        sinon.collection.stub @peerConnection, 'setLocalDescription'

      @creator.successCallback(onLocalDescriptionSuccess)(description)

      expect(setLocalDescription).to.have.been.calledWith(
        description, onLocalDescriptionSuccess, @failureCallback
      )

  describe 'failureCallback', ->
    it 'logs the error', ->
      error = sinon.collection.stub console, 'error'

      @creator.failureCallback(errorString = 'AAAHHH')

      expect(error).to.have.been.calledWith errorString
