expect = require('chai').expect

describe 'PeerConnectionUtil', ->
  beforeEach ->
    @peerConnectionUtil = require('../../private/peer-connection-util.js')

  describe '.createPeerConnection', ->
    beforeEach ->
      vegaObservatory = {}
      peerId = 'peerId'
      peerConnectionConfig = {}
      @pcConstructor = (arg) ->
        throw new Error 'must include peer connection config!' if !arg
      @peerConnection = @peerConnectionUtil.createPeerConnection(vegaObservatory, peerId, peerConnectionConfig, @pcConstructor)

    it 'returns an RTCPeerConnection', ->
      expect(@peerConnection).to.be.instanceOf @pcConstructor
