VegaClient = require('vega-client')
PeerConnectionFactory = require('./private/peer-connection-factory')
SessionDescriptionCreator = require('./private/session-description-creator')
PeerStore = require('./private/peer-store')
WebRTCInterop = require('../webrtc-interop/webrtc-interop.js')

class VegaObservatory
  constructor: (@options) ->
    @vegaClient = new VegaClient(@options.url, @options.roomId, @options.badge)
    @peerConnectionFactory =
      @options.peerConnectionFactory || PeerConnectionFactory
    @sessionDescriptionCreator =
      @options.sessionDescriptionCreator || SessionDescriptionCreator
    @webRTCInterop = @options.webRTCInterop || WebRTCInterop
    @callbacks = {}
    @peerStore = @options.peerStore || new PeerStore

    @webRTCInterop.infectGlobal()
    @_setClientCallbacks()

  call: ->
    @vegaClient.call()

  sendOffer: (offer, peerId) ->
    @vegaClient.offer(offer, peerId)

  sendAnswer: (answer, peerId) ->
    @vegaClient.answer(answer, peerId)

  sendCandidate: (candidate, peerId) ->
    @vegaClient.candidate(candidate, peerId)

  hangUp: ->
    @vegaClient.hangUp()

  createOffer: (peerId) ->
    peerConnection = @_peerConnection(peerId)

    @sessionDescriptionCreator.forOffer(
      this, peerId, peerConnection
    )

  createAnswer: (peerId) ->
    peerConnection = @_peerConnection(peerId)

    @sessionDescriptionCreator.forAnswer(
      this, peerId, peerConnection
    )

  onStreamAdded: (f) ->
    @peerStore.on 'streamAdded', f

  onPeerRemoved: (f) ->
    @peerStore.on 'remove', f
    
  addStream: (peerId, stream) ->
    @peerStore.addStream(peerId, stream)

  _setClientCallbacks: ->
    @vegaClient.on 'callAccepted', (payload) =>
      @_handleCallAccepted payload

    @vegaClient.on 'offer', (payload) =>
      @_handleOffer payload

    @vegaClient.on 'answer', (payload) =>
      @_handleAnswer payload

    @vegaClient.on 'candidate', (payload) =>
      @_handleCandidate payload

    @vegaClient.on 'peerHangUp', (payload) =>
      @_handlePeerHangUp payload

  _handleCallAccepted: (peers) ->
    peers.forEach (peer) =>
      @_addPeerToStore peer

    @trigger 'callAccepted', peers

  _handleOffer: (payload) ->
    peer       = new Object(payload)
    peer.offer = undefined
    peerConnection = @_addPeerToStore payload
    @_handleSessionDescription(peerConnection, 'offer', payload)

  _handleAnswer: (payload) ->
    peerConnection = @_peerConnection(payload.peerId)
    @_handleSessionDescription(peerConnection, 'answer', payload)

  _handleSessionDescription: (peerConnection, descriptionType, payload) ->
    sessionDescription = new RTCSessionDescription(payload[descriptionType])

    peerConnection.setRemoteDescription(sessionDescription)

    @trigger descriptionType, payload

  _handleCandidate: (payload) ->
    peerConnection = @_peerConnection(payload.peerId)
    iceCandidate   = new RTCIceCandidate(payload.candidate)

    peerConnection.addIceCandidate(iceCandidate)

    @trigger 'candidate', payload

  _handlePeerHangUp: (payload) ->
    @trigger 'peerHangUp', payload
    @peerStore.remove(payload.peerId)

  _addPeerToStore: (peer) ->
    peerConnection = @peerConnectionFactory.create(
      this,
      peer,
      @options.peerConnectionConfig
    )

    peer.peerConnection = peerConnection

    @peerStore.add peer

    peerConnection

  _peerConnection: (peerId) ->
    @_findPeer(peerId).peerConnection

  _findPeer: (peerId) ->
    @peerStore.find(peerId)

  on: (event, callback) ->
    @callbacks[event] ||= []
    @callbacks[event].push(callback)

  trigger: (event) ->
    args = Array.prototype.slice.call(arguments, 1)

    if callbacks = @callbacks[event]
      callbacks.forEach (callback) ->
        callback.apply(this, args)

module.exports = VegaObservatory
