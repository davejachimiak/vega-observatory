VegaClient            = require('vega-client')
PeerConnectionFactory = require('./private/peer-connection-factory')

class VegaObservatory
  constructor: (@options) ->
    @vegaClient = new VegaClient(@options.url, @options.roomId, @options.badge)
    @peerConnectionFactory = PeerConnectionFactory
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
    @vegaClient.on 'callAccepted', (payload) =>
      @_handleCallAccepted(payload)

    @vegaClient.on 'offer', (payload) =>
      peerConnection = @_addPeerToStore payload
      @_handleSessionDescription(peerConnection, 'offer', payload)

    @vegaClient.on 'answer', (payload) =>
      peerConnection = @peerStore[payload.peerId].peerConnection
      @_handleSessionDescription(peerConnection, 'answer', payload)

    @vegaClient.on 'candidate', (payload) =>
      peerConnection = @peerStore[payload.peerId].peerConnection
      iceCandidate   = new RTCIceCandidate(payload.candidate)

      peerConnection.addIceCandidate(iceCandidate)

      @trigger 'candidate', payload

    @vegaClient.on 'peerHangUp', (payload) =>
      @trigger 'peerHangUp', payload

  _handleCallAccepted: (peers) =>
    peers.forEach (peer) =>
      @_addPeerToStore(peer)

    @trigger 'callAccepted', peers

  _handleSessionDescription: (peerConnection, descriptionType, payload) ->
    sessionDescription = new RTCSessionDescription(payload[descriptionType])

    peerConnection.setRemoteDescription(sessionDescription)

    @trigger descriptionType, payload

  _addPeerToStore: (peer) ->
    peerConnection = @peerConnectionFactory.create()

    @peerStore[peer.peerId] =
      badge: peer.badge
      peerConnection: peerConnection

    peerConnection

module.exports = VegaObservatory
