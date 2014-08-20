require('../test-helper')

PeerStore = require('../../private/peer-store')

describe 'PeerStore', ->
  beforeEach ->
    @peerStore = new PeerStore

  describe '#add', ->
    it 'adds a peer to the stores', ->
      peer = new Object

      @peerStore.add(peer)

      expect(@peerStore.peers).to.eql [peer]

  describe '#remove', ->

  describe '#addStream', ->

  describe '#on', ->

  describe '#withStream', ->

  describe '#withoutStream', ->
