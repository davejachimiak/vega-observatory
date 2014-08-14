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

    @vegaClient.on 'offer', (payload) =>
      peerConnection = new WebRTCPeerConnection

      @peerStore[payload.peerId] =
        badge: payload.badge
        peerConnection: peerConnection

  _handleCallAccepted: (peers) =>
    peers.forEach (peer) =>
      peerConnection = new WebRTCPeerConnection

      @peerStore[peer.peerId] =
        badge: peer.badge
        peerConnection: peerConnection

    @trigger 'callAccepted', peers

module.exports = VegaObservatory
