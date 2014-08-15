expect = require('chai').expect

describe 'PeerConnectionUtil', ->
  beforeEach ->
    @peerConnectionUtil = require('../../private/peer-connection-util.js')

  describe '.createPeerConnection', ->
    beforeEach ->
      vegaObservatory = {}
      peerId = 'peerId'
      @pcConstructor = (arg) ->
        if !arg
          throw new Error 'must include peer connection config!'
      @peerConnection = @peerConnectionUtil.createPeerConnection(vegaObservatory, peerId, @pcConstructor)

    it 'returns an RTCPeerConnection', ->
      expect(@peerConnection).to.be.instanceOf @pcConstructor
