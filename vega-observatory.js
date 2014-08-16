// Generated by CoffeeScript 1.7.1
(function() {
  var VegaClient, VegaObservatory;

  VegaClient = require('vega-client');

  VegaObservatory = (function() {
    function VegaObservatory(options) {
      this.options = options;
      this.vegaClient = new VegaClient(this.options.url, this.options.roomId, this.options.badge);
      this.peerConnectionFactory = this.options.peerConnectionFactory || PeerConnectionFactory;
      this.sessionDescriptionCreator = this.options.sessionDescriptionCreator || new SessionDescriptionCreator;
      this.callbacks = {};
      this.peerStore = {};
      this._setClientCallbacks();
    }

    VegaObservatory.prototype.call = function() {
      return this.vegaClient.call();
    };

    VegaObservatory.prototype.createOffer = function(peerId) {
      var peerConnection;
      peerConnection = this._peerConnection(peerId);
      return this.sessionDescriptionCreator.forOffer(this, peerId, peerConnection);
    };

    VegaObservatory.prototype.createAnswer = function(peerId) {
      var peerConnection;
      peerConnection = this._peerConnection(peerId);
      return this.sessionDescriptionCreator.forAnswer(this, peerId, peerConnection);
    };

    VegaObservatory.prototype._setClientCallbacks = function() {
      this.vegaClient.on('callAccepted', (function(_this) {
        return function(payload) {
          return _this._handleCallAccepted(payload);
        };
      })(this));
      this.vegaClient.on('offer', (function(_this) {
        return function(payload) {
          return _this._handleOffer(payload);
        };
      })(this));
      this.vegaClient.on('answer', (function(_this) {
        return function(payload) {
          return _this._handleAnswer(payload);
        };
      })(this));
      this.vegaClient.on('candidate', (function(_this) {
        return function(payload) {
          return _this._handleCandidate(payload);
        };
      })(this));
      return this.vegaClient.on('peerHangUp', (function(_this) {
        return function(payload) {
          return _this._handlePeerHangUp(payload);
        };
      })(this));
    };

    VegaObservatory.prototype._handleCallAccepted = function(peers) {
      peers.forEach((function(_this) {
        return function(peer) {
          return _this._addPeerToStore(peer);
        };
      })(this));
      return this.trigger('callAccepted', peers);
    };

    VegaObservatory.prototype._handleOffer = function(payload) {
      var peer, peerConnection;
      peer = new Object(payload);
      peer.offer = null;
      peerConnection = this._addPeerToStore(peer);
      return this._handleSessionDescription(peerConnection, 'offer', payload);
    };

    VegaObservatory.prototype._handleAnswer = function(payload) {
      var peerConnection;
      peerConnection = this._peerConnection(payload.peerId);
      return this._handleSessionDescription(peerConnection, 'answer', payload);
    };

    VegaObservatory.prototype._handleSessionDescription = function(peerConnection, descriptionType, payload) {
      var sessionDescription;
      sessionDescription = new RTCSessionDescription(payload[descriptionType]);
      peerConnection.setRemoteDescription(sessionDescription);
      return this.trigger(descriptionType, payload);
    };

    VegaObservatory.prototype._handleCandidate = function(payload) {
      var iceCandidate, peerConnection;
      peerConnection = this._peerConnection(payload.peerId);
      iceCandidate = new RTCIceCandidate(payload.candidate);
      peerConnection.addIceCandidate(iceCandidate);
      return this.trigger('candidate', payload);
    };

    VegaObservatory.prototype._handlePeerHangUp = function(payload) {
      this.trigger('peerHangUp', payload);
      return delete this.peerStore[payload.peerId];
    };

    VegaObservatory.prototype._addPeerToStore = function(peer) {
      var peerConnection;
      peerConnection = this.peerConnectionFactory.create(this, peer, this.options.peerConnectionConfig);
      this.peerStore[peer.peerId] = {
        badge: peer.badge,
        peerConnection: peerConnection
      };
      return peerConnection;
    };

    VegaObservatory.prototype._peerConnection = function(peerId) {
      return this.peerStore[peerId].peerConnection;
    };

    VegaObservatory.prototype.on = function(event, callback) {
      var _base;
      (_base = this.callbacks)[event] || (_base[event] = []);
      return this.callbacks[event].push(callback);
    };

    VegaObservatory.prototype.trigger = function(event) {
      var args, callbacks;
      args = Array.prototype.slice.call(arguments, 1);
      if (callbacks = this.callbacks[event]) {
        return callbacks.forEach(function(callback) {
          return callback.apply(this, args);
        });
      }
    };

    return VegaObservatory;

  })();

  module.exports = VegaObservatory;

}).call(this);
