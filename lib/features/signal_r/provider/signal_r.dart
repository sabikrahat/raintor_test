import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:signalr_core/signalr_core.dart';

import '../../../core/config/environment.dart';

typedef SignalRNotifier = AsyncNotifierProvider<SignalRProvider, void>;

final signalRProvider = SignalRNotifier(SignalRProvider.new);

class SignalRProvider extends AsyncNotifier<void> {
  late HubConnection hubConnection;
  String myLocation = 'Waiting for my current location...';
  List<String> otherUserLocation = [];
  bool _isReconnecting = false;

  Set<Marker> liveMarkers = {};
  LatLng? myLatLng;

  @override
  FutureOr<void> build() async {
    await _initializeConnection();
    _receiver();
    _myLiveLocation();

    ref.onDispose(() async {
      log('Disposing SignalR connection');
      try {
        await hubConnection.stop();
        log('SignalR Disconnected');
      } catch (e) {
        log('Error while stopping SignalR: $e');
      }
    });
  }

  Future<void> _initializeConnection() async {
    hubConnection = HubConnectionBuilder()
        .withUrl(
          Environment.signalRUrl,
          HttpConnectionOptions(logging: (level, message) => log(message)),
        )
        .build();

    hubConnection.onclose((error) {
      log('SignalR Disconnected: ${error?.toString() ?? "no error"}');
      _retryConnection();
    });

    try {
      await hubConnection.start();
      log('SignalR Connected');
    } catch (e) {
      log('Initial connection failed: $e');
      _retryConnection();
    }
  }

  Future<void> _retryConnection() async {
    if (_isReconnecting) return;

    _isReconnecting = true;
    int retries = 0;
    const maxRetries = 5;

    while (hubConnection.state != HubConnectionState.connected && retries < maxRetries) {
      await Future.delayed(Duration(seconds: 2 * (retries + 1)));
      log('Reconnection attempt ${retries + 1}');
      try {
        await hubConnection.start();
        log('Reconnected to SignalR');
        _isReconnecting = false;
        return;
      } catch (e) {
        retries++;
        log('Reconnection failed: $e');
      }
    }

    log('Max retries reached. SignalR remains disconnected.');
    _isReconnecting = false;
  }

  void _receiver() {
    try {
      hubConnection.on('ReceiveLatLon', (arguments) {
        log('Received location payload: $arguments');
        if (arguments != null) {
          otherUserLocation.clear();
          liveMarkers.removeWhere((m) => m.markerId.value != 'me');

          for (var arg in arguments) {
            try {
              if (arg is Map && arg.containsKey('lat') && arg.containsKey('lon')) {
                final lat = arg['lat'] as double;
                final lon = arg['lon'] as double;
                final userName = arg['userName'] ?? 'Unknown User';

                otherUserLocation.add('$userName → Lat: $lat, Lon: $lon');

                liveMarkers.add(
                  Marker(
                    markerId: MarkerId(userName),
                    position: LatLng(lat, lon),
                    infoWindow: InfoWindow(title: userName),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  ),
                );
              }
            } catch (e) {
              log('Error parsing data item: $e');
            }
          }

          ref.notifyListeners();
        } else {
          log('Received data is empty or in unexpected format');
        }
      });
    } catch (e) {
      log('Error setting up receiver: $e');
    }
  }

  Future<void> _myLiveLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        log('Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      log('Location permission permanently denied.');
      return;
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen((Position position) async {
      final lat = position.latitude;
      final lon = position.longitude;
      myLatLng = LatLng(lat, lon);
      final userName = 'sabikrahat72428@gmail.com';
      myLocation = 'My Location → Lat: $lat, Lon: $lon';

      liveMarkers.removeWhere((m) => m.markerId.value == 'me');
      liveMarkers.add(
        Marker(
          markerId: const MarkerId('me'),
          position: LatLng(lat, lon),
          infoWindow: const InfoWindow(title: 'Me'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      ref.notifyListeners();

      if (hubConnection.state == HubConnectionState.connected) {
        try {
          await hubConnection.invoke('SendLatLon', args: [lat, lon, userName]);
        } catch (e) {
          log('Error sending location: $e');
        }
      }
    });
  }
}
