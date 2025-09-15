import 'package:busmitra/models/route_model.dart';
import 'package:geolocator/geolocator.dart';


class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permissions
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permissions
  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  // Get current user location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check permissions
      LocationPermission permission = await checkLocationPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestLocationPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // Calculate distance between two points in kilometers
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  // Find the nearest bus stop to user's current location
  RouteStop? findNearestStop(List<RouteStop> stops, double userLat, double userLon) {
    if (stops.isEmpty) return null;

    RouteStop nearestStop = stops.first;
    double minDistance = calculateDistance(
      userLat, 
      userLon, 
      nearestStop.latitude, 
      nearestStop.longitude
    );

    for (RouteStop stop in stops) {
      double distance = calculateDistance(
        userLat, 
        userLon, 
        stop.latitude, 
        stop.longitude
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        nearestStop = stop;
      }
    }

    return nearestStop;
  }

  // Get distance to nearest stop
  double getDistanceToNearestStop(List<RouteStop> stops, double userLat, double userLon) {
    RouteStop? nearestStop = findNearestStop(stops, userLat, userLon);
    if (nearestStop == null) return 0.0;
    
    return calculateDistance(
      userLat, 
      userLon, 
      nearestStop.latitude, 
      nearestStop.longitude
    );
  }

  // Check if user is near a bus stop (within 200 meters)
  bool isNearBusStop(List<RouteStop> stops, double userLat, double userLon, {double radiusKm = 0.2}) {
    for (RouteStop stop in stops) {
      double distance = calculateDistance(userLat, userLon, stop.latitude, stop.longitude);
      if (distance <= radiusKm) {
        return true;
      }
    }
    return false;
  }

  // Get the next upcoming stops based on user's current location
  List<RouteStop> getUpcomingStops(List<RouteStop> stops, double userLat, double userLon) {
    if (stops.isEmpty) return [];

    // Find the nearest stop
    RouteStop? nearestStop = findNearestStop(stops, userLat, userLon);
    if (nearestStop == null) return [];

    // Get stops that come after the nearest stop in the route sequence
    List<RouteStop> upcomingStops = stops
        .where((stop) => stop.sequence > nearestStop.sequence)
        .toList();

    return upcomingStops;
  }

  // Calculate estimated time to reach a stop (assuming average bus speed of 25 km/h)
  int getEstimatedTimeToStop(double distanceKm, {double averageSpeedKmh = 25.0}) {
    double timeInHours = distanceKm / averageSpeedKmh;
    return (timeInHours * 60).round(); // Convert to minutes
  }

  // Get formatted distance string
  String getFormattedDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }

  // Get formatted time string
  String getFormattedTime(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours hr';
      } else {
        return '$hours hr $remainingMinutes min';
      }
    }
  }
}
