class PeerConnectionUtil
  @createPeerConnection: (observatory, peerId, pcConstructor=RTCPeerConnection) ->
    new pcConstructor

  @descriptionCallbacks: ->

module.exports = PeerConnectionUtil
