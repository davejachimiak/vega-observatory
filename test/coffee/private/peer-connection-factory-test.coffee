require('../test-helper')

describe 'PeerConnectionFactory', ->
  beforeEach ->
    @peerConnectionFactory = require('../../private/peer-connection-factory.js')

  afterEach ->
    sinon.collection.restore()

  describe '.createPeerConnection', ->
    beforeEach ->
      @vegaObservatory =
        trigger: ->
        sendCandidate: ->
        addStream: ->
        localStream: @localStream = new Object
      @peerId = 'peerId'
      @peer =
        peerId: @peerId
        badge: { name: 'Dave' }
      peerConnectionConfig = {}

      @pcConstructor = (arg) =>
        unless arg is peerConnectionConfig
          throw new Error 'must include peer connection config!'

        addStream: (stream) =>
          @streamAdded = stream

      @peerConnection = @peerConnectionFactory.create(@vegaObservatory, @peer, peerConnectionConfig, @pcConstructor)

    it 'adds the local stream', ->
      expect(@streamAdded).to.eq @localStream

    it 'sends a candidate through the vega client on ice candidate', ->
      sendCandidate = sinon.collection.stub @vegaObservatory, 'sendCandidate'
      event =
        candidate: { cool: 'stuff' }

      @peerConnection.onicecandidate(event)

      expect(sendCandidate).to.have.been.calledWith event.candidate, @peerId

    it 'adds the stream to the observatory when a stream is added', ->
      addStream = sinon.collection.stub @vegaObservatory, 'addStream'
      event   = { stream: 'an audio/video stream' }

      @peerConnection.onaddstream(event)

      expect(addStream).to.have.been.calledWith @peer.peerId, event.stream
