chai      = require('chai')
sinon     = require('sinon')
sinonChai = require('sinon-chai')
expect    = chai.expect

chai.use sinonChai

describe 'PeerConnectionUtil', ->
  beforeEach ->
    @peerConnectionUtil = require('../../private/peer-connection-util.js')

  describe '.createPeerConnection', ->
    beforeEach ->
      @vegaClient = candidate: ->
      vegaObservatory =
        vegaClient: @vegaClient
      @peerId = 'peerId'
      peerConnectionConfig = {}
      @pcConstructor = (arg) ->
        unless arg is peerConnectionConfig
          throw new Error 'must include peer connection config!'

      @peerConnection = @peerConnectionUtil.createPeerConnection(vegaObservatory, @peerId, peerConnectionConfig, @pcConstructor)

    it 'returns an RTCPeerConnection', ->
      expect(@peerConnection).to.be.instanceOf @pcConstructor

    it 'sends a candidate through the vega client on ice candidate', ->
      candidate = sinon.collection.stub @vegaClient, 'candidate'
      event =
        candidate: { cool: 'stuff' }

      @peerConnection.onicecandidate(event)

      expect(candidate).to.have.been.calledWith event.candidate, @peerId
