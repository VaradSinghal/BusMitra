import 'package:busmitra/models/bus_model.dart';
import 'package:busmitra/models/route_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';


class DatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all available routes
  Future<List<BusRoute>> getRoutes() async {
    try {
      final query = await _firestore.collection('routes').get();
      final List<BusRoute> routes = [];
      for (final doc in query.docs) {
        final route = await _busRouteFromFirestoreDoc(doc);
        if (route != null) routes.add(route);
      }
      return routes;
    } catch (e) {
      print('Error fetching routes: $e');
      return [];
    }
  }

  // Get active buses for a specific route (realtime stream)
  Stream<List<Bus>> getActiveBuses(String routeId) {
    return _database.ref('active_drivers').onValue.map((event) {
      final List<Bus> buses = [];
      
      if (event.snapshot.exists) {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        
        data.forEach((driverId, busData) {
          final busMap = Map<String, dynamic>.from(busData as Map<dynamic, dynamic>);
          if (busMap['routeId'] == routeId && _isDriverActive(busMap)) {
            buses.add(Bus.fromMap(driverId, busMap));
          }
        });
      }
      
      return buses;
    });
  }

  // Get all active buses across all routes (realtime stream)
  Stream<List<Bus>> getAllActiveBuses() {
    return _database.ref('active_drivers').onValue.map((event) {
      final List<Bus> buses = [];
      
      if (event.snapshot.exists) {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        
        data.forEach((driverId, busData) {
          final busMap = Map<String, dynamic>.from(busData as Map<dynamic, dynamic>);
          if (_isDriverActive(busMap)) {
            buses.add(Bus.fromMap(driverId, busMap));
          }
        });
      }
      
      return buses;
    });
  }

  // Get a specific bus by driver ID (realtime stream)
  Stream<Bus?> getBusByDriverId(String driverId) {
    return _database.ref('active_drivers/$driverId').onValue.map((event) {
      if (event.snapshot.exists) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          event.snapshot.value as Map<dynamic, dynamic>
        );
        return Bus.fromMap(driverId, data);
      }
      return null;
    });
  }

  // Get route by ID
  Future<BusRoute?> getRouteById(String routeId) async {
    try {
      final doc = await _firestore.collection('routes').doc(routeId).get();
      if (!doc.exists) return null;
      return _busRouteFromFirestoreDoc(doc);
    } catch (e) {
      print('Error fetching route: $e');
      return null;
    }
  }

  // Get active routes (routes that have active buses)
  Stream<List<BusRoute>> getActiveRoutes() {
    return _database.ref('active_drivers').onValue.asyncMap((event) async {
      final Set<String> activeRouteIds = <String>{};
      
      if (event.snapshot.exists) {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        
        data.forEach((driverId, busData) {
          final busMap = Map<String, dynamic>.from(busData as Map<dynamic, dynamic>);
          if (_isDriverActive(busMap)) {
            activeRouteIds.add(busMap['routeId']?.toString() ?? '');
          }
        });
      }

      // Fetch route details for active routes
      final List<BusRoute> activeRoutes = [];
      for (String routeId in activeRouteIds) {
        if (routeId.isNotEmpty) {
          final route = await getRouteById(routeId);
          if (route != null) {
            activeRoutes.add(route);
          }
        }
      }

      return activeRoutes;
    });
  }

  // Get bus count for a specific route
  Stream<int> getBusCountForRoute(String routeId) {
    return _database.ref('active_drivers').onValue.map((event) {
      int count = 0;
      
      if (event.snapshot.exists) {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        
        data.forEach((driverId, busData) {
          final busMap = Map<String, dynamic>.from(busData as Map<dynamic, dynamic>);
          if (busMap['routeId'] == routeId && _isDriverActive(busMap)) {
            count++;
          }
        });
      }
      
      return count;
    });
  }

  // Get connection status summary
  Stream<Map<String, int>> getConnectionStatusSummary() {
    return _database.ref('active_drivers').onValue.map((event) {
      final Map<String, int> summary = {
        'connected': 0,
        'connecting': 0,
        'disconnected': 0,
        'total': 0,
      };
      
      if (event.snapshot.exists) {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        
        data.forEach((driverId, busData) {
          final busMap = Map<String, dynamic>.from(busData as Map<dynamic, dynamic>);
          final status = busMap['connectionStatus']?.toString().toLowerCase() ?? 'disconnected';
          
          if (summary.containsKey(status)) {
            summary[status] = summary[status]! + 1;
          }
          summary['total'] = summary['total']! + 1;
        });
      }
      
      return summary;
    });
  }

  bool _isDriverActive(Map<String, dynamic> busMap) {
    final bool isOnDuty = busMap['isOnDuty'] == true;
    if (!isOnDuty) return false;

    final String status = busMap['connectionStatus']?.toString().toLowerCase() ?? '';
    final bool isOnline = busMap['isOnline'] == true;
    final int ts = (busMap['timestamp'] is int) ? busMap['timestamp'] as int : 0;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final bool isRecent = ts > 0 && (now - ts) < 5 * 60 * 1000; // 5 minutes

    return status == 'connected' || isOnline || isRecent;
  }

  // Build BusRoute from Firestore doc supporting either embedded stops array/map or subcollection
  Future<BusRoute?> _busRouteFromFirestoreDoc(DocumentSnapshot<Map<String, dynamic>> doc) async {
    try {
      final data = doc.data();
      if (data == null) return null;

      Map<String, dynamic> routeMap = Map<String, dynamic>.from(data);

      // Try to load stops from subcollection if present
      List<RouteStop> stops = [];
      try {
        final stopsQuery = await doc.reference.collection('stops').orderBy('sequence').get();
        if (stopsQuery.docs.isNotEmpty) {
          for (final stopDoc in stopsQuery.docs) {
            final stopData = stopDoc.data();
            final stop = RouteStop.fromMap({
              'id': stopDoc.id,
              ...stopData,
            });
            stops.add(stop);
          }
        }
      } catch (_) {
        // ignore, fallback to embedded
      }

      if (stops.isEmpty && routeMap['stops'] != null) {
        final stopsData = routeMap['stops'];
        if (stopsData is List) {
          for (final s in stopsData) {
            if (s is Map) {
              stops.add(RouteStop.fromMap(Map<String, dynamic>.from(s)));
            }
          }
        } else if (stopsData is Map) {
          (stopsData).forEach((key, value) {
            if (value is Map) {
              final m = Map<String, dynamic>.from(value);
              m['id'] = m['id']?.toString() ?? key.toString();
              stops.add(RouteStop.fromMap(m));
            }
          });
        }
        stops.sort((a, b) => a.sequence.compareTo(b.sequence));
      }

      final enriched = {
        ...routeMap,
        'stops': {
          for (final s in stops) s.id: {
            'id': s.id,
            'name': s.name,
            'latitude': s.latitude,
            'longitude': s.longitude,
            'sequence': s.sequence,
          }
        }
      };

      return BusRoute.fromMap(doc.id, enriched);
    } catch (e) {
      print('Error parsing route ${doc.id}: $e');
      return null;
    }
  }

  // Get Google Directions API route polyline
  Future<List<LatLng>> getRoutePolyline(List<RouteStop> stops) async {
    if (stops.length < 2) return [];

    try {
      final origin = '${stops.first.latitude},${stops.first.longitude}';
      final destination = '${stops.last.latitude},${stops.last.longitude}';
      final waypoints = stops.length > 2 
          ? stops.skip(1).take(stops.length - 2)
              .map((stop) => '${stop.latitude},${stop.longitude}')
              .join('|')
          : '';

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$origin'
        '&destination=$destination'
        '${waypoints.isNotEmpty ? '&waypoints=$waypoints' : ''}'
        '&mode=driving'
        '&key=AIzaSyCL8UnJJxGrTj-7Y09yYGXn24tcae-XrQk'
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          return _decodePolyline(points);
        }
      }
    } catch (e) {
      print('Error fetching route polyline: $e');
    }
    return [];
  }

  List<LatLng> _decodePolyline(String polyline) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < polyline.length) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }
}