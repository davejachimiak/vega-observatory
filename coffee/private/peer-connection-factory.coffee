class PeerConnectionFactory
  @create: (observatory, peer, config, pcConstructor=RTCPeerConnection) ->
    peerCandidate = new pcConstructor(config)
    peerId        = peer.peerId

    peerCandidate.onicecandidate = (event) ->
      if candidate = event.candidate
        observatory.sendCandidate(candidate, peerId)

    peerCandidate.onaddstream = (event) ->
      observatory.trigger 'remoteStreamAdded', peer, event.stream

    peerCandidate

module.exports = PeerConnectionFactory
