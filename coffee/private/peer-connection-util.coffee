class PeerConnectionUtil
  @createPeerConnection: (observatory, peer, config, pcConstructor=RTCPeerConnection) ->
    vegaClient    = observatory.vegaClient
    peerCandidate = new pcConstructor(config)
    peerId        = peer.peerId

    peerCandidate.onicecandidate = (event) ->
      if candidate = event.candidate
        vegaClient.candidate(candidate, peerId)

    peerCandidate.onaddstream = (event) ->
      observatory.trigger 'remoteStreamAdded', peer, event.stream

    peerCandidate

  @descriptionCallbacks: ->

module.exports = PeerConnectionUtil
