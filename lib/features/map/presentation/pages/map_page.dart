import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/data_sources/favorite_locations.dart';
import '../../data/models/favorite_location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _initialPosition = LatLng(22.8026, 89.3709);
  static const double _initialZoom = 12.5;

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  Position? _currentPosition;
  bool _isLoadingLocation = false;
  String? _locationMessage;

  Set<Marker> get _markers {
    return favoriteLocations.map((location) {
      return Marker(
        markerId: MarkerId('favorite_${location.id}'),
        position: LatLng(location.latitude, location.longitude),
        infoWindow: InfoWindow(
          title: location.name,
          snippet: 'ID: ${location.id} • Tap for details',
          onTap: () => _showLocationDetails(location),
        ),
        onTap: () => _showLocationDetails(location),
      );
    }).toSet();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    if (!_mapController.isCompleted) {
      _mapController.complete(controller);
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (_isLoadingLocation) return;

    setState(() {
      _isLoadingLocation = true;
      _locationMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _locationMessage = 'Location services are disabled.';
        });
        await _showLocationError(
          'Location services are disabled. Please turn on location services and try again.',
          showOpenSettings: true,
        );
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = 'Location permission was denied.';
        });
        await _showLocationError(
          'Location permission was denied. Please allow location access to use My Location.',
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationMessage = 'Location permission is permanently denied.';
        });
        await _showLocationError(
          'Location permission is permanently denied. Open app settings and allow location access.',
          showOpenSettings: true,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _locationMessage = null;
      });

      final controller = await _mapController.future;
      final target = LatLng(position.latitude, position.longitude);

      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: target,
            zoom: 16,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _locationMessage = 'Could not get your current location.';
      });

      await _showLocationError(
        'Could not get your current location. Please check GPS/location permissions and try again.\n\n$error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _showLocationError(
    String message, {
    bool showOpenSettings = false,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Location'),
          content: Text(message),
          actions: [
            if (showOpenSettings)
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Geolocator.openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _moveToFavorite(FavoriteLocation location) async {
    final controller = await _mapController.future;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(location.latitude, location.longitude),
          zoom: 16,
        ),
      ),
    );
  }

  Future<void> _zoomIn() async {
    final controller = await _mapController.future;
    await controller.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    final controller = await _mapController.future;
    await controller.animateCamera(CameraUpdate.zoomOut());
  }

  void _showLocationDetails(FavoriteLocation location) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Favorite Location',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _detailRow('ID', '${location.id}'),
                _detailRow('Name', location.name),
                _detailRow('Latitude', location.latitude.toStringAsFixed(4)),
                _detailRow('Longitude', location.longitude.toStringAsFixed(4)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _moveToFavorite(location);
                    },
                    icon: const Icon(Icons.center_focus_strong),
                    label: const Text('Move Camera Here'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showFavoriteLocations() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Favorite Locations',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap an item to move the map to that location.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                ...favoriteLocations.map(
                  (location) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.star),
                      ),
                      title: Text(
                        location.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        'ID: ${location.id}  •  '
                        '${location.latitude.toStringAsFixed(4)}, '
                        '${location.longitude.toStringAsFixed(4)}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.of(context).pop();
                        _moveToFavorite(location);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Google Maps & Location',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
       actions: [
      Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton.icon(
      onPressed: _showFavoriteLocations,
      icon: const Icon(Icons.star),
      label: const Text('Favorite Locations'),
    ),
  ),
],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: _initialZoom,
            ),
            onMapCreated: _onMapCreated,
            markers: _markers,
            zoomControlsEnabled: false,
            myLocationEnabled: _currentPosition != null,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: true,
          ),

          Positioned(
            right: 16,
            top: 16,
            child: _MapControlGroup(
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
            ),
          ),

          Positioned(
            right: 16,
            bottom: 26,
            child: FloatingActionButton.extended(
              heroTag: 'my_location',
              onPressed: _isLoadingLocation ? null : _goToCurrentLocation,
              icon: _isLoadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(
                _isLoadingLocation ? 'Getting Location...' : 'My Location',
              ),
            ),
          ),

          if (_locationMessage != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 98,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_locationMessage!)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapControlGroup extends StatelessWidget {
  const _MapControlGroup({
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          IconButton(
            tooltip: 'Zoom in',
            onPressed: onZoomIn,
            icon: const Icon(Icons.add),
          ),
          const Divider(height: 1),
          IconButton(
            tooltip: 'Zoom out',
            onPressed: onZoomOut,
            icon: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
