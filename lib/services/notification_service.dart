import 'package:busmitra/models/bus_model.dart';
import 'package:busmitra/models/route_model.dart';
import 'package:busmitra/services/location_service.dart';
import 'package:busmitra/utils/constants.dart';
import 'package:flutter/material.dart';


class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final LocationService _locationService = LocationService();
  
  // Track notification states to avoid spam
  final Map<String, DateTime> _lastNotificationTimes = {};
  final Map<String, bool> _busArrivalNotifications = {};

  // Show bus arrival notification
  void showBusArrivalNotification({
    required BuildContext context,
    required Bus bus,
    required RouteStop stop,
    required double userLat,
    required double userLon,
  }) {
    final notificationKey = '${bus.driverId}_${stop.id}';
    final now = DateTime.now();
    
    // Check if we already notified for this bus-stop combination recently
    if (_lastNotificationTimes.containsKey(notificationKey)) {
      final lastNotification = _lastNotificationTimes[notificationKey]!;
      if (now.difference(lastNotification).inMinutes < 5) {
        return; // Don't spam notifications
      }
    }

    final distance = _locationService.calculateDistance(
      userLat, userLon, stop.latitude, stop.longitude,
    );

    // Only notify if bus is within 500 meters of the stop
    if (distance <= 0.5) {
      _showNotification(
        context: context,
        title: 'Bus Arriving Soon!',
        message: '${bus.busNumber} is approaching ${stop.name}',
        type: NotificationType.busArrival,
        onTap: () {
          // TODO: Navigate to bus tracking screen
        },
      );
      
      _lastNotificationTimes[notificationKey] = now;
    }
  }

  // Show bus departure notification
  void showBusDepartureNotification({
    required BuildContext context,
    required Bus bus,
    required RouteStop stop,
  }) {
    final notificationKey = 'departure_${bus.driverId}_${stop.id}';
    final now = DateTime.now();
    
    if (_lastNotificationTimes.containsKey(notificationKey)) {
      final lastNotification = _lastNotificationTimes[notificationKey]!;
      if (now.difference(lastNotification).inMinutes < 2) {
        return;
      }
    }

    _showNotification(
      context: context,
      title: 'Bus Departed',
      message: '${bus.busNumber} has left ${stop.name}',
      type: NotificationType.busDeparture,
    );
    
    _lastNotificationTimes[notificationKey] = now;
  }

  // Show route update notification
  void showRouteUpdateNotification({
    required BuildContext context,
    required String routeName,
    required String message,
  }) {
    _showNotification(
      context: context,
      title: 'Route Update: $routeName',
      message: message,
      type: NotificationType.routeUpdate,
    );
  }

  // Show connection status notification
  void showConnectionNotification({
    required BuildContext context,
    required bool isConnected,
  }) {
    if (isConnected) {
      _showNotification(
        context: context,
        title: 'Connection Restored',
        message: 'Live tracking is now active',
        type: NotificationType.connection,
      );
    } else {
      _showNotification(
        context: context,
        title: 'Connection Lost',
        message: 'Unable to fetch live bus locations',
        type: NotificationType.connection,
        isError: true,
      );
    }
  }

  // Show general notification
  void _showNotification({
    required BuildContext context,
    required String title,
    required String message,
    required NotificationType type,
    bool isError = false,
    VoidCallback? onTap,
  }) {
    final color = _getNotificationColor(type, isError);
    final icon = _getNotificationIcon(type, isError);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: onTap != null ? SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: onTap,
        ) : null,
      ),
    );
  }

  Color _getNotificationColor(NotificationType type, bool isError) {
    if (isError) return AppConstants.errorColor;
    
    switch (type) {
      case NotificationType.busArrival:
        return Colors.green;
      case NotificationType.busDeparture:
        return Colors.orange;
      case NotificationType.routeUpdate:
        return AppConstants.primaryColor;
      case NotificationType.connection:
        return Colors.blue;
    }
  }

  IconData _getNotificationIcon(NotificationType type, bool isError) {
    if (isError) return Icons.error;
    
    switch (type) {
      case NotificationType.busArrival:
        return Icons.directions_bus;
      case NotificationType.busDeparture:
        return Icons.departure_board;
      case NotificationType.routeUpdate:
        return Icons.route;
      case NotificationType.connection:
        return Icons.wifi;
    }
  }

  // Clear old notification timestamps to prevent memory leaks
  void clearOldNotifications() {
    final now = DateTime.now();
    _lastNotificationTimes.removeWhere((key, time) {
      return now.difference(time).inHours > 24;
    });
  }
}

enum NotificationType {
  busArrival,
  busDeparture,
  routeUpdate,
  connection,
}
