class BusRoute {
  final String id;
  final String name;
  final String startPoint;
  final String endPoint;
  final double distance;
  final int estimatedTime;
  final List<RouteStop> stops;
  final bool active;

  BusRoute({
    required this.id,
    required this.name,
    required this.startPoint,
    required this.endPoint,
    required this.distance,
    required this.estimatedTime,
    required this.stops,
    required this.active,
  });

  factory BusRoute.fromMap(String id, Map<String, dynamic> map) {
    List<RouteStop> stops = [];
    final stopsData = map['stops'];
    
    if (stopsData is Map<dynamic, dynamic>) {
      stopsData.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          stops.add(RouteStop.fromMap(Map<String, dynamic>.from(value)));
        }
      });
      // Sort stops by sequence
      stops.sort((a, b) => a.sequence.compareTo(b.sequence));
    }
    
    return BusRoute(
      id: id,
      name: map['name']?.toString() ?? '',
      startPoint: map['startPoint']?.toString() ?? '',
      endPoint: map['endPoint']?.toString() ?? '',
      distance: (map['distance'] is double) 
          ? map['distance'] as double 
          : (map['distance'] is int) 
            ? (map['distance'] as int).toDouble() 
            : 0.0,
      estimatedTime: (map['estimatedTime'] is int) 
          ? map['estimatedTime'] as int 
          : 0,
      stops: stops,
      active: map['active'] as bool? ?? false,
    );
  }
}

class RouteStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int sequence;

  RouteStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.sequence,
  });

  factory RouteStop.fromMap(Map<String, dynamic> map) {
    return RouteStop(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      latitude: (map['latitude'] is double) 
          ? map['latitude'] as double 
          : (map['latitude'] is int) 
            ? (map['latitude'] as int).toDouble() 
            : 0.0,
      longitude: (map['longitude'] is double) 
          ? map['longitude'] as double 
          : (map['longitude'] is int) 
            ? (map['longitude'] as int).toDouble() 
            : 0.0,
      sequence: (map['sequence'] is int) ? map['sequence'] as int : 0,
    );
  }
}