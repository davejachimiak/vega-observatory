describe 'VegaObservatory', ->
  beforeEach ->
    window.WebRTCPeerConnection = ->
    options =
      url: 'ws://0.0.0.0:3000'
      roomId: '/abc123'
      badge: {}
    @vegaObservatory = new VegaObservatory options
    @vegaClient = @vegaObservatory.vegaClient

  describe '#call', ->
    it 'delegates to the vega client', ->
      call = sinon.collection.stub @vegaClient, 'call'

      @vegaObservatory.call()

      expect(call).to.have.been.called

  describe 'callbacks', ->
    describe 'on callAccepted', ->
      beforeEach ->
        @peer1 = { peerId: 'peerId1', badge: { name: 'Dave' } }
        @peer2 = { peerId: 'peerId2', badge: { name: 'Allie' } }
        @peers = [@peer1, @peer2]
        sinon.collection.stub(window, 'WebRTCPeerConnection').
          returns @peerConnection = {}

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

        @vegaObservatory.on 'callAccepted', (peers) ->
          object.peers = peers

        @vegaClient.trigger('callAccepted', @peers)

        expect(object.peers).to.eq @peers
