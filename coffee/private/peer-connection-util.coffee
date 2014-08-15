class PeerConnectionUtil
  @createPeerConnection: (observatory, peerId, config, pcConstructor=RTCPeerConnection) ->
    vegaClient    = observatory.vegaClient
    peerCandidate = new pcConstructor(config)

    peerCandidate.onicecandidate = (event) ->
      if candidate = event.candidate
        vegaClient.candidate(candidate, peerId)

    peerCandidate

  @descriptionCallbacks: ->

module.exports = PeerConnectionUtil
