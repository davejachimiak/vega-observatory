require('../test-helper')

PeerStore = require('../../private/peer-store')

describe 'PeerStore', ->
  beforeEach ->
    @peerStore = new PeerStore

  describe '#add', ->
    beforeEach ->
      @peer = new Object

    it 'adds a peer to the stores', ->
      @peerStore.add(@peer)

      expect(@peerStore.peers).to.eql [@peer]

    it 'triggers an add event', ->
      @peerStore.on 'add', (peer) =>
        @thePeer = peer

      @peerStore.add(@peer)

      expect(@thePeer).to.eq @peer

  describe '#remove', ->

  describe '#addStream', ->

  describe '#withStream', ->

  describe '#withoutStream', ->
