class PeerStore
  callbacks: {}
  peers: []

  constructor: (@options) ->
    @URL = @options?.URL || global.URL

  add: (peer) ->
    @peers.push peer
    @trigger 'add', peer

  addStream: (peerId, stream) ->
    peer = undefined

    @peers.forEach (p) ->
      return peer = p if p.peerId is peerId

    peer.stream = stream
    peer.streamUrl = @URL.createObjectURL(stream)

    @trigger 'streamAdded', peer

  remove: (peerId) ->
    removedPeer = undefined
    peers       = []
    
    @peers.forEach (peer) ->
      if peer.peerId is peerId
        removedPeer = peer
      else
        peers.push peer

    @peers = peers

    @trigger 'remove', removedPeer

  find: (peerId) ->
    peer = undefined

    @peers.forEach (p) ->
      return peer = p if p.peerId is peerId

    peer

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
