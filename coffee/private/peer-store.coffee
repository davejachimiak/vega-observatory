class PeerStore
  callbacks: {}
  peers: []

  add: (peer) ->
    @peers.push peer
    @trigger 'add', peer

  addStream: (peerId, stream) ->
    thePeer = null

    @peers.forEach (peer) ->
      return thePeer = peer if peer.peerId is peerId

    thePeer.stream = stream

    @trigger 'streamAdded', thePeer

  remove: (peerId) ->
    removedPeer = null
    newPeers    = []
    
    @peers.forEach (peer) ->
      if peer.peerId is peerId
        removedPeer = peer
      else
        newPeers.push peer

    @peers = newPeers

    @trigger 'remove', removedPeer

  find: (peerId) ->
    foundPeer = undefined

    @peers.forEach (peer) ->
      return foundPeer = peer if peer.peerId is peerId

    foundPeer

  peersWithStreams: ->
    peersWithStreams = []

    @peers.forEach (peer) =>
      peersWithStreams.push(peer) if @_hasStream peer

    peersWithStreams

  peersWithoutStreams: ->
    peersWithoutStreams = []

    @peers.forEach (peer) =>
      peersWithoutStreams.push(peer) if not @_hasStream peer

    peersWithoutStreams

  on: (event, callback) ->
    @callbacks[event] ||= []
    @callbacks[event].push callback

  trigger: (event) ->
    args = Array.prototype.slice.call(arguments, 1)

    if callbacks = @callbacks[event]
      callbacks.forEach (callback) ->
        callback.apply(this, args)

  _hasStream: (peer) ->
    not not peer.stream

module.exports = PeerStore
