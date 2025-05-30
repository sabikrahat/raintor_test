import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'core/config/environment.dart';
import 'core/router/go_routes.dart';
import 'package:signalr_core/signalr_core.dart';

void main() async {
  await _init();
  runApp(ProviderScope(child: const App()));
}

Future<void> _init() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: Environment.fileName);
}

class App extends StatelessWidget {
  const App({super.key = const Key('Raintor-Test')});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Raintor Test',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'RaintorTest',
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late HubConnection hubConnection;
  String myLocation = 'Waiting for location...';
  String otherUserLocation = 'Waiting for incoming location...';

  @override
  void initState() {
    super.initState();
    initSignalR();
  }

  Future<void> initSignalR() async {
    hubConnection = HubConnectionBuilder()
        .withUrl(
          Environment.signalRUrl,
          HttpConnectionOptions(logging: (level, message) => log(message)),
        )
        .build();

    // Set up receiver (User B)
    hubConnection.on('ReceiveLatLon', (arguments) {
      final lat = arguments?[0];
      final lon = arguments?[1];
      setState(() {
        otherUserLocation = 'Received → Lat: $lat, Lon: $lon';
      });
      log('📡 Received location: Lat: $lat, Lon: $lon');
    });

    await hubConnection.start();
    log('✅ SignalR Connected');

    // Start sending location (User A)
    startLocationTracking();
  }

  Future<void> startLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log('❌ Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        log('❌ Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      log('❌ Location permission permanently denied.');
      return;
    }

    Geolocator.getPositionStream().listen((Position position) async {
      final lat = position.latitude;
      final lon = position.longitude;
      setState(() {
        myLocation = 'My Location → Lat: $lat, Lon: $lon';
      });
      log('📍 Sending location: Lat: $lat, Lon: $lon');

      // Send location to server
      if (hubConnection.state == HubConnectionState.connected) {
        try {
          await hubConnection.invoke('SendLatLon', args: [lat, lon]);
        } catch (e) {
          log('⚠️ Error sending location: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    hubConnection.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignalR Location Sharing',
      home: Scaffold(
        appBar: AppBar(title: const Text('Real-Time Location (SignalR)')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(myLocation, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Text(otherUserLocation, style: const TextStyle(fontSize: 16, color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }
}
