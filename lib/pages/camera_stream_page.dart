import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;

class CameraStreamPage extends StatefulWidget {
  final String feedType;

  const CameraStreamPage({super.key, required this.feedType});

  @override
  State<CameraStreamPage> createState() => _CameraStreamPageState();
}

class _CameraStreamPageState extends State<CameraStreamPage> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  String _status = "Connecting...";

  @override
  void initState() {
    super.initState();
    _initRendererAndStart();
  }

  Future<void> _initRendererAndStart() async {
    await _localRenderer.initialize();
    await _startWebRTC();
  }

  Future<void> _startWebRTC() async {
    try {
      final config = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {
            'urls': 'turn:numb.viagenie.ca',
            'username': 'webrtc@live.com',
            'credential': 'muazkh'
          }
        ],
        'iceTransportPolicy': 'all',
      };


      _peerConnection = await createPeerConnection(config);

      _peerConnection!.onIceConnectionState = (state) {
        print("🔌 ICE connection state: $state");
      };

      _peerConnection!.onConnectionState = (state) {
        print("📡 Peer connection state: $state");
      };

      _peerConnection!.onIceGatheringState = (state) {
        print("📶 ICE gathering state: $state");
      };

      _peerConnection!.onIceCandidate = (candidate) {
        print("🧊 ICE candidate: ${candidate.candidate}");
      };

      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': false,
        'video': {
          'facingMode': 'environment',
        },
      });

      print("📸 Got local video stream: ${_localStream!.id}");

      _localRenderer.srcObject = _localStream;

      final videoTrack = _localStream!.getVideoTracks()[0];
      print("📦 Adding video track: ${videoTrack.id}");
      _peerConnection!.addTrack(videoTrack, _localStream!);

      await Future.delayed(const Duration(milliseconds: 500));

      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      print("📤 Sending offer SDP...");
      setState(() => _status = "Sending offer...");

      final response = await http.post(
        Uri.parse('http://20.24.49.239:8000/offer?feed_type=${widget.feedType}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sdp': offer.sdp, 'type': offer.type}),
      );

      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body);
        final answer = RTCSessionDescription(resBody['sdp'], resBody['type']);
        await _peerConnection!.setRemoteDescription(answer);
        setState(() => _status = "📡 Streaming to server");
      } else {
        setState(() => _status = "❌ Offer failed");
        print("❌ Server response code: ${response.statusCode}");
        print("❌ Server response body: ${response.body}");
      }
    } catch (e) {
      setState(() => _status = "❌ Error: $e");
      print("❌ WebRTC error: $e");
    }
  }

  @override
  void dispose() {
    _localStream?.dispose();
    _peerConnection?.dispose();
    _localRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RTCVideoView(
            _localRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.6),
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Text(
                  "${widget.feedType.toUpperCase()} Feed - $_status",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
