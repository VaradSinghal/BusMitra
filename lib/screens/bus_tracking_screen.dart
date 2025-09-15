import 'package:busmitra/models/bus_model.dart';
import 'package:busmitra/models/route_model.dart';
import 'package:busmitra/services/database_service.dart';
import 'package:busmitra/services/location_service.dart';
import 'package:busmitra/services/notification_service.dart';
import 'package:busmitra/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


class BusTrackingScreen extends StatefulWidget {
  final BusRoute route;
  final Position? userLocation;

  const BusTrackingScreen({
    super.key,
    required this.route,
    this.userLocation,
  });

  @override
  State<BusTrackingScreen> createState() => _BusTrackingScreenState();
}

class _BusTrackingScreenState extends State<BusTrackingScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  
  GoogleMapController? _mapController;
  List<Bus> _activeBuses = [];
  Position? _currentUserLocation;
  RouteStop? _nearestStop;
  List<RouteStop> _upcomingStops = [];
  bool _isLoading = true;
  String? _errorMessage;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  DateTime _lastUpdate = DateTime.now();
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get current user location
      await _getCurrentUserLocation();

      // Set up map markers and polylines
      _setupMapData();

      // Listen to active buses for this route
      _listenToActiveBuses();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize tracking: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentUserLocation() async {
    try {
      if (widget.userLocation != null) {
        _currentUserLocation = widget.userLocation;
      } else {
        final position = await _locationService.getCurrentLocation();
        if (position != null) {
          _currentUserLocation = position;
        }
      }

      if (_currentUserLocation != null) {
        // Find nearest stop
        _nearestStop = _locationService.findNearestStop(
          widget.route.stops,
          _currentUserLocation!.latitude,
          _currentUserLocation!.longitude,
        );

        // Get upcoming stops
        _upcomingStops = _locationService.getUpcomingStops(
          widget.route.stops,
          _currentUserLocation!.latitude,
          _currentUserLocation!.longitude,
        );
      }
    } catch (e) {
      print('Error getting user location: $e');
    }
  }

  void _setupMapData() {
    _createStopMarkers();
    _createRoutePolyline();
    _createUserLocationMarker();
  }

  void _createStopMarkers() {
    _markers.clear();
    
    for (RouteStop stop in widget.route.stops) {
      final isNearestStop = _nearestStop?.id == stop.id;
      final isUpcomingStop = _upcomingStops.any((upcoming) => upcoming.id == stop.id);
      
      _markers.add(
        Marker(
          markerId: MarkerId('stop_${stop.id}'),
          position: LatLng(stop.latitude, stop.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isNearestStop 
                ? BitmapDescriptor.hueBlue
                : isUpcomingStop 
                    ? BitmapDescriptor.hueGreen
                    : BitmapDescriptor.hueViolet,
          ),
          infoWindow: InfoWindow(
            title: stop.name,
            snippet: 'Stop ${stop.sequence}',
          ),
        ),
      );
    }
  }

  void _createRoutePolyline() {
    if (widget.route.stops.length < 2) return;

    final List<LatLng> points = widget.route.stops
        .map((stop) => LatLng(stop.latitude, stop.longitude))
        .toList();

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: AppConstants.primaryColor,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    );
  }

  void _createUserLocationMarker() {
    if (_currentUserLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(
            _currentUserLocation!.latitude,
            _currentUserLocation!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Current position',
          ),
        ),
      );
    }
  }

  void _createBusMarkers() {
    // Remove existing bus markers
    _markers.removeWhere((marker) => marker.markerId.value.startsWith('bus_'));
    
    for (Bus bus in _activeBuses) {
      _markers.add(
        Marker(
          markerId: MarkerId('bus_${bus.driverId}'),
          position: LatLng(bus.latitude, bus.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            bus.connectionStatusColor == Colors.green 
                ? BitmapDescriptor.hueGreen
                : bus.connectionStatusColor == Colors.orange
                    ? BitmapDescriptor.hueOrange
                    : BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: bus.busNumber,
            snippet: '${bus.driverName} • ${bus.connectionStatus}',
          ),
          rotation: bus.heading,
        ),
      );
    }
  }

  void _listenToActiveBuses() {
    _databaseService.getActiveBuses(widget.route.id).listen((buses) {
      final wasConnected = _isConnected;
      
      setState(() {
        _activeBuses = buses;
        _lastUpdate = DateTime.now();
        _isConnected = true;
      });
      
      _createBusMarkers();
      _updateNearestStopInfo();
      _checkBusArrivals(buses);
      
      // Show connection restored notification
      if (!wasConnected && _isConnected) {
        _notificationService.showConnectionNotification(
          context: context,
          isConnected: true,
        );
      }
    }, onError: (error) {
      final wasConnected = _isConnected;
      setState(() {
        _isConnected = false;
      });
      
      // Show connection lost notification
      if (wasConnected && !_isConnected) {
        _notificationService.showConnectionNotification(
          context: context,
          isConnected: false,
        );
      }
    });
  }

  void _checkBusArrivals(List<Bus> buses) {
    if (_currentUserLocation == null) return;
    
    for (Bus bus in buses) {
      for (RouteStop stop in widget.route.stops) {
        final distance = _locationService.calculateDistance(
          bus.latitude,
          bus.longitude,
          stop.latitude,
          stop.longitude,
        );
        
        // Check if bus is approaching a stop (within 500m)
        if (distance <= 0.5) {
          _notificationService.showBusArrivalNotification(
            context: context,
            bus: bus,
            stop: stop,
            userLat: _currentUserLocation!.latitude,
            userLon: _currentUserLocation!.longitude,
          );
        }
      }
    }
  }

  void _updateNearestStopInfo() {
    if (_currentUserLocation != null && _activeBuses.isNotEmpty) {
      // Find the nearest bus to user
      Bus? nearestBus;
      double minDistance = double.infinity;
      
      for (Bus bus in _activeBuses) {
        final distance = _locationService.calculateDistance(
          _currentUserLocation!.latitude,
          _currentUserLocation!.longitude,
          bus.latitude,
          bus.longitude,
        );
        
        if (distance < minDistance) {
          minDistance = distance;
          nearestBus = bus;
        }
      }
      
      if (nearestBus != null) {
        // Update nearest stop based on nearest bus position
        _nearestStop = _locationService.findNearestStop(
          widget.route.stops,
          nearestBus.latitude,
          nearestBus.longitude,
        );
        
        // Update upcoming stops
        _upcomingStops = _locationService.getUpcomingStops(
          widget.route.stops,
          nearestBus.latitude,
          nearestBus.longitude,
        );
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _fitMapToRoute();
  }

  void _fitMapToRoute() {
    if (_mapController == null || widget.route.stops.isEmpty) return;

    final LatLngBounds bounds = _calculateBounds();
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }

  LatLngBounds _calculateBounds() {
    double minLat = widget.route.stops.first.latitude;
    double maxLat = widget.route.stops.first.latitude;
    double minLng = widget.route.stops.first.longitude;
    double maxLng = widget.route.stops.first.longitude;

    for (RouteStop stop in widget.route.stops) {
      minLat = minLat < stop.latitude ? minLat : stop.latitude;
      maxLat = maxLat > stop.latitude ? maxLat : stop.latitude;
      minLng = minLng < stop.longitude ? minLng : stop.longitude;
      maxLng = maxLng > stop.longitude ? maxLng : stop.longitude;
    }

    // Include user location if available
    if (_currentUserLocation != null) {
      minLat = minLat < _currentUserLocation!.latitude ? minLat : _currentUserLocation!.latitude;
      maxLat = maxLat > _currentUserLocation!.latitude ? maxLat : _currentUserLocation!.latitude;
      minLng = minLng < _currentUserLocation!.longitude ? minLng : _currentUserLocation!.longitude;
      maxLng = maxLng > _currentUserLocation!.longitude ? maxLng : _currentUserLocation!.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.route.name),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.accentColor,
        elevation: 0,
        actions: [
          // Connection status indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _isConnected ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  _isConnected ? 'Live' : 'Offline',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _fitMapToRoute,
          ),
        ],
      ),
      body: _buildBody(),
      bottomSheet: _buildBottomSheet(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading map...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeTracking,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: widget.route.stops.isNotEmpty
            ? LatLng(widget.route.stops.first.latitude, widget.route.stops.first.longitude)
            : const LatLng(28.7041, 77.1025), // Default to Delhi
        zoom: 12.0,
      ),
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Route info
          _buildRouteInfo(),
          const SizedBox(height: 16),
          
          // Nearest stop info
          if (_nearestStop != null) _buildNearestStopInfo(),
          
          // Active buses info
          if (_activeBuses.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildActiveBusesInfo(),
          ],
          
          // Upcoming stops info
          if (_upcomingStops.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildUpcomingStopsInfo(),
          ],
          
          // Last update info
          const SizedBox(height: 16),
          _buildLastUpdateInfo(),
        ],
      ),
    );
  }

  Widget _buildRouteInfo() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.route.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.route.startPoint} → ${widget.route.endPoint}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${widget.route.distance.toStringAsFixed(1)} km',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            Text(
              '${widget.route.estimatedTime} min',
              style: TextStyle(
                fontSize: 12,
                color: AppConstants.lightTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNearestStopInfo() {
    final distance = _currentUserLocation != null
        ? _locationService.calculateDistance(
            _currentUserLocation!.latitude,
            _currentUserLocation!.longitude,
            _nearestStop!.latitude,
            _nearestStop!.longitude,
          )
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppConstants.primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nearest Stop',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _nearestStop!.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
            Text(
              _locationService.getFormattedDistance(distance),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveBusesInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_bus, color: AppConstants.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Active Buses (${_activeBuses.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...(_activeBuses.map((bus) => _buildBusInfo(bus))),
        ],
      ),
    );
  }

  Widget _buildBusInfo(Bus bus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppConstants.lightTextColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: bus.connectionStatusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bus.busNumber,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  bus.driverName,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppConstants.lightTextColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${bus.speed.toStringAsFixed(1)} km/h',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingStopsInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.arrow_forward, color: AppConstants.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Upcoming Stops (${_upcomingStops.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...(_upcomingStops.take(3).map((stop) => _buildUpcomingStopItem(stop))),
          if (_upcomingStops.length > 3)
            Text(
              '... and ${_upcomingStops.length - 3} more stops',
              style: TextStyle(
                fontSize: 12,
                color: AppConstants.lightTextColor,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingStopItem(RouteStop stop) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppConstants.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              stop.name,
              style: const TextStyle(
                fontSize: 12,
                color: AppConstants.textColor,
              ),
            ),
          ),
          Text(
            'Stop ${stop.sequence}',
            style: TextStyle(
              fontSize: 10,
              color: AppConstants.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdateInfo() {
    final now = DateTime.now();
    final difference = now.difference(_lastUpdate);
    String updateText;
    
    if (difference.inSeconds < 60) {
      updateText = 'Updated ${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      updateText = 'Updated ${difference.inMinutes}m ago';
    } else {
      updateText = 'Updated ${difference.inHours}h ago';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppConstants.lightTextColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _isConnected ? Icons.sync : Icons.sync_problem,
            size: 16,
            color: _isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            updateText,
            style: TextStyle(
              fontSize: 12,
              color: AppConstants.lightTextColor,
            ),
          ),
          const Spacer(),
          if (!_isConnected)
            Text(
              'Connection lost',
              style: TextStyle(
                fontSize: 12,
                color: AppConstants.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
