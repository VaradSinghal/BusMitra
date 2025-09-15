import 'package:flutter/material.dart';

class Bus {
  final String driverId;
  final String routeId;
  final String routeName;
  final String driverName;
  final String busNumber;
  final double latitude;
  final double longitude;
  final double speed;
  final double heading;
  final double accuracy;
  final String connectionStatus;
  final bool isOnDuty;
  final bool isOnline;
  final int heartbeat;
  final int lastSeen;
  final int timestamp;
  final int updateCount;

  Bus({
    required this.driverId,
    required this.routeId,
    required this.routeName,
    required this.driverName,
    required this.busNumber,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.heading,
    required this.accuracy,
    required this.connectionStatus,
    required this.isOnDuty,
    required this.isOnline,
    required this.heartbeat,
    required this.lastSeen,
    required this.timestamp,
    required this.updateCount,
  });

  factory Bus.fromMap(String driverId, Map<String, dynamic> map) {
    return Bus(
      driverId: driverId,
      routeId: map['routeId']?.toString() ?? '',
      routeName: map['routeName']?.toString() ?? '',
      driverName: map['driverName']?.toString() ?? 'Unknown Driver',
      busNumber: map['busNumber']?.toString() ?? 'Unknown Bus',
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
      speed: (map['speed'] is double) 
          ? map['speed'] as double 
          : (map['speed'] is int) 
            ? (map['speed'] as int).toDouble() 
            : 0.0,
      heading: (map['heading'] is double) 
          ? map['heading'] as double 
          : (map['heading'] is int) 
            ? (map['heading'] as int).toDouble() 
            : 0.0,
      accuracy: (map['accuracy'] is double) 
          ? map['accuracy'] as double 
          : (map['accuracy'] is int) 
            ? (map['accuracy'] as int).toDouble() 
            : 0.0,
      connectionStatus: map['connectionStatus']?.toString() ?? 'disconnected',
      isOnDuty: map['isOnDuty'] as bool? ?? false,
      isOnline: map['isOnline'] as bool? ?? false,
      heartbeat: (map['heartbeat'] is int) ? map['heartbeat'] as int : 0,
      lastSeen: (map['lastSeen'] is int) ? map['lastSeen'] as int : 0,
      timestamp: (map['timestamp'] is int) ? map['timestamp'] as int : 0,
      updateCount: (map['updateCount'] is int) ? map['updateCount'] as int : 0,
    );
  }

  // Helper method to check if bus data is recent (within last 5 minutes)
  bool get isDataRecent {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - timestamp) < 300000; // 5 minutes in milliseconds
  }

  // Helper method to get connection status color
  Color get connectionStatusColor {
    switch (connectionStatus.toLowerCase()) {
      case 'connected':
        return Colors.green;
      case 'connecting':
        return Colors.orange;
      case 'disconnected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}