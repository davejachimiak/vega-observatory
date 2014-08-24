class PeerConnectionFactory
  @create: (observatory, peer, config, pcConstructor=RTCPeerConnection) ->
    peerConnection = new pcConstructor(config)
    localStream    = observatory.localStream
    peerId         = peer.peerId

    peerConnection.addStream localStream

    peerConnection.onicecandidate = (event) ->
      if candidate = event.candidate
        observatory.sendCandidate(candidate, peerId)

    peerConnection.onaddstream = (event) ->
      observatory.addStream peerId, event.stream

    peerConnection

module.exports = PeerConnectionFactory
