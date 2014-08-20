require('../test-helper')

SessionDescriptionCreator = require('../../private/session-description-creator.js')

describe 'SessionDescriptionCreator', ->
  beforeEach ->
    @observatory      =
      sendOffer: ->
      sendAnswer: ->
    @peerId           = 'an peer id'
    @localDescription = { aGood: 'desc' }

    @peerConnection =
      createOffer: ->
      createAnswer: ->
      setLocalDescription: ->
      localDescription: @localDescription

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

  describe '#successCallback', ->
    it 'returns a callback that sets a local description with proper args', ->
      onLocalDescriptionSuccess = ->
      description = 'description'
      setLocalDescription =
        sinon.collection.stub @peerConnection, 'setLocalDescription'

      @creator.successCallback(onLocalDescriptionSuccess)(description)

      expect(setLocalDescription).to.have.been.calledWith(
        description, onLocalDescriptionSuccess, @failureCallback
      )

  describe '#failureCallback', ->
    it 'logs the error', ->
      error = sinon.collection.stub console, 'error'

      @creator.failureCallback(errorString = 'AAAHHH')

      expect(error).to.have.been.calledWith errorString

  describe '#sendOffer', ->
    it 'delegates to the observatory', ->
      sendOffer = sinon.collection.stub @observatory, 'sendOffer'

      @creator.sendOffer()

      expect(sendOffer).to.have.been.calledWith(
        @localDescription, @peerId
      )

  describe '#sendAnswer', ->
    it 'delegates to the observatory', ->
      sendAnswer = sinon.collection.stub @observatory, 'sendAnswer'

      @creator.sendAnswer()

      expect(sendAnswer).to.have.been.calledWith(
        @localDescription, @peerId
      )
