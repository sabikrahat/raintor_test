import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../provider/signal_r.dart';

class SignalRView extends ConsumerStatefulWidget {
  const SignalRView({super.key});

  static const String name = 'signal-r';

  @override
  ConsumerState<SignalRView> createState() => _SignalRViewState();
}

class _SignalRViewState extends ConsumerState<SignalRView> {
  GoogleMapController? _mapController;
  int _currentFocusIndex = 0;
  final List<LatLng> _cameraTargets = [];

  void _cycleCameraTargets(SignalRProvider notifier) {
    _cameraTargets.clear();

    if (notifier.myLatLng != null) {
      _cameraTargets.add(notifier.myLatLng!);
    }

    // Add other marker locations excluding 'me'
    final others = notifier.liveMarkers
        .where((marker) => marker.markerId.value != 'me')
        .map((marker) => marker.position);
    _cameraTargets.addAll(others);

    if (_cameraTargets.isEmpty) return;

    // Cycle through each target
    final target = _cameraTargets[_currentFocusIndex % _cameraTargets.length];
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 14)),
    );

    _currentFocusIndex++;
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(signalRProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
          ),
          data: (_) {
            final notifier = ref.watch(signalRProvider.notifier);
            final initialLatLng =
                notifier.myLatLng ?? const LatLng(23.8103, 90.4125); // default location (Dhaka)
            return Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      flex: 6,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(target: initialLatLng, zoom: 14),
                        markers: notifier.liveMarkers,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              notifier.myLocation,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              notifier.otherUserLocation.isEmpty
                                  ? 'Waiting for incoming location...'
                                  : notifier.otherUserLocation.join('\n'),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton.small(
                onPressed: () => _cycleCameraTargets(notifier),
                child: const Icon(Icons.location_searching),
              ),
            );
          },
        );
  }
}
