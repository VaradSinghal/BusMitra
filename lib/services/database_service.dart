import 'package:busmitra/models/bus_model.dart';
import 'package:busmitra/models/route_model.dart';
import 'package:firebase_database/firebase_database.dart';


class DatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Get all available routes
  Future<List<BusRoute>> getRoutes() async {
    try {
      final snapshot = await _database.ref('routes').get();
      if (snapshot.exists) {
        final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        return data.entries.map((entry) {
          return BusRoute.fromMap(entry.key, Map<String, dynamic>.from(entry.value));
        }).toList();
      }
      return [];
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
          if (busMap['routeId'] == routeId && 
              busMap['isOnline'] == true && 
              busMap['isOnDuty'] == true) {
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
          if (busMap['isOnline'] == true && busMap['isOnDuty'] == true) {
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
      final snapshot = await _database.ref('routes/$routeId').get();
      if (snapshot.exists) {
        return BusRoute.fromMap(routeId, Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>));
      }
      return null;
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
          if (busMap['isOnline'] == true && busMap['isOnDuty'] == true) {
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
          if (busMap['routeId'] == routeId && 
              busMap['isOnline'] == true && 
              busMap['isOnDuty'] == true) {
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
}