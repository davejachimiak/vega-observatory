describe 'VegaObservatory', ->
  beforeEach ->
    class window.RTCSessionDescription

    options =
      url: 'ws://0.0.0.0:3000'
      roomId: '/abc123'
      badge: {}
    @vegaObservatory = new VegaObservatory options
    @peerConnectionFactory = @vegaObservatory.peerConnectionFactory
    @vegaClient = @vegaObservatory.vegaClient

  afterEach ->
    sinon.collection.restore()

  describe '#call', ->
    it 'delegates to the vega client', ->
      call = sinon.collection.stub @vegaClient, 'call'

      @vegaObservatory.call()

      expect(call).to.have.been.called

  describe 'callbacks', ->
    beforeEach ->
      sinon.collection.stub(@peerConnectionFactory, 'create').
        returns @peerConnection = setRemoteDescription: ->

    describe 'on callAccepted', ->
      beforeEach ->
        @peer1 = { peerId: 'peerId1', badge: { name: 'Dave' } }
        @peer2 = { peerId: 'peerId2', badge: { name: 'Allie' } }
        @peers = [@peer1, @peer2]

      it 'saves references to all peers in the response', ->
        @vegaClient.trigger('callAccepted', @peers)

        expect(@vegaObservatory.peerStore).to.eql
          "peerId1":
            badge: @peer1.badge
            peerConnection: @peerConnection
          "peerId2":
            badge: @peer2.badge
            peerConnection: @peerConnection

      it 'triggers a callAccepted event on the observatory', ->
        object = {}

        @vegaObservatory.on 'callAccepted', (payload) ->
          object.peers = payload

        @vegaClient.trigger('callAccepted', @peers)

        expect(object.peers).to.eq @peers

    describe 'on offer', ->
      beforeEach ->
        @badge = { name: 'Dave' }
        @payload =
          peerId: 'peerId'
          badge: @badge
          offer: { 'offer key': 'offer value' }

        @setRemoteDescription =
          sinon.collection.stub @peerConnection, 'setRemoteDescription'

        @rtcSessionDescription = sinon.createStubInstance(window.RTCSessionDescription)

      it 'saves a reference to the peer', ->
        @vegaClient.trigger 'offer', @payload

        expect(@vegaObservatory.peerStore).to.eql
          "peerId":
            badge: @badge
            peerConnection: @peerConnection

      it 'sets the offer on the peer connection', ->
        @vegaClient.trigger 'offer', @payload

        expect(@setRemoteDescription).to.have.been.calledWith @rtcSessionDescription

      it 'triggers an offer event', ->
        object = {}

        @vegaObservatory.on 'offer', (payload) ->
          object.payload = payload

        @vegaClient.trigger('offer', @payload)

        expect(object.payload).to.eq @payload
