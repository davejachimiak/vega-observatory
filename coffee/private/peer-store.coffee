class PeerStore
  peers: []

  add: (peer) ->
    @peers.push peer

module.exports = PeerStore
