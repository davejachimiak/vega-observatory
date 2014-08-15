// Generated by CoffeeScript 1.7.1
(function() {
  var PeerConnectionUtil;

  PeerConnectionUtil = (function() {
    function PeerConnectionUtil() {}

    PeerConnectionUtil.createPeerConnection = function(observatory, peerId, pcConstructor) {
      if (pcConstructor == null) {
        pcConstructor = RTCPeerConnection;
      }
      return new pcConstructor;
    };

    PeerConnectionUtil.descriptionCallbacks = function() {};

    return PeerConnectionUtil;

  })();

  module.exports = PeerConnectionUtil;

}).call(this);
