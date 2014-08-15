class PeerConnectionUtil
  @createPeerConnection: (observatory, peerId, config, pcConstructor=RTCPeerConnection) ->
    new pcConstructor(config)

  @descriptionCallbacks: ->

module.exports = PeerConnectionUtil
