VegaClient = require('vega-client')

class VegaObservatory
  constructor: (@options) ->
    @vegaClient = new VegaClient(@options.url, @options.roomId, @options.badge)
    @callbacks = {}
    @peerStore = {}
    @_setClientCallbacks()

  call: ->
    @vegaClient.call()

  on: (event, callback) ->
    @callbacks[event] ||= []
    @callbacks[event].push(callback)

  trigger: (event) ->
    args = Array.prototype.slice.call(arguments, 1)

    if callbacks = @callbacks[event]
      callbacks.forEach (callback) ->
        callback.apply(this, args)

  _setClientCallbacks: ->
    @vegaClient.on 'callAccepted', (payload) => @_handleCallAccepted(payload)

    @vegaClient.on 'offer', (payload) => @_addPeerToStore payload

  _handleCallAccepted: (peers) =>
    peers.forEach (peer) => @_addPeerToStore(peer)
    @trigger 'callAccepted', peers

  _addPeerToStore: (peer) ->
    peerConnection = new WebRTCPeerConnection

    @peerStore[peer.peerId] =
      badge: peer.badge
      peerConnection: peerConnection

module.exports = VegaObservatory
