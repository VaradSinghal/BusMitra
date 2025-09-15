import 'package:busmitra/models/bus_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusMarker extends StatelessWidget {
  final Bus bus;
  final VoidCallback? onTap;

  const BusMarker({
    super.key,
    required this.bus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: bus.connectionStatusColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.directions_bus,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  // Create a BitmapDescriptor for the bus marker
  static Future<BitmapDescriptor> createBusMarkerIcon(Bus bus) async {
    // Create a custom marker icon based on bus status
    final Color statusColor = bus.connectionStatusColor;
    
    // For now, return a default bus icon
    // In a real implementation, you might want to create a custom bitmap
    return BitmapDescriptor.defaultMarkerWithHue(
      _getHueFromColor(statusColor),
    );
  }

  // Convert Color to hue value for BitmapDescriptor
  static double _getHueFromColor(Color color) {
    if (color == Colors.green) return BitmapDescriptor.hueGreen;
    if (color == Colors.orange) return BitmapDescriptor.hueOrange;
    if (color == Colors.red) return BitmapDescriptor.hueRed;
    return BitmapDescriptor.hueBlue;
  }
}

// Custom bus info window widget
class BusInfoWindow extends StatelessWidget {
  final Bus bus;

  const BusInfoWindow({
    super.key,
    required this.bus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bus number and status
          Row(
            children: [
              Icon(
                Icons.directions_bus,
                color: bus.connectionStatusColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                bus.busNumber,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: bus.connectionStatusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  bus.connectionStatus.toUpperCase(),
                  style: TextStyle(
                    color: bus.connectionStatusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Driver name
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                bus.driverName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          
          // Route name
          Row(
            children: [
              const Icon(Icons.route, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  bus.routeName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Speed and last update
          Row(
            children: [
              const Icon(Icons.speed, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '${bus.speed.toStringAsFixed(1)} km/h',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              Text(
                _getLastUpdateText(),
                style: TextStyle(
                  fontSize: 12,
                  color: bus.isDataRecent ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getLastUpdateText() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - bus.timestamp;
    final minutes = (diff / 60000).round();
    
    if (minutes < 1) {
      return 'Just now';
    } else if (minutes < 60) {
      return '$minutes min ago';
    } else {
      final hours = (minutes / 60).round();
      return '$hours hr ago';
    }
  }
}

// Bus marker with info window
class BusMarkerWithInfo extends StatefulWidget {
  final Bus bus;
  final VoidCallback? onTap;

  const BusMarkerWithInfo({
    super.key,
    required this.bus,
    this.onTap,
  });

  @override
  State<BusMarkerWithInfo> createState() => _BusMarkerWithInfoState();
}

class _BusMarkerWithInfoState extends State<BusMarkerWithInfo> {
  bool _showInfo = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Bus marker
        BusMarker(
          bus: widget.bus,
          onTap: () {
            setState(() {
              _showInfo = !_showInfo;
            });
            widget.onTap?.call();
          },
        ),
        
        // Info window
        if (_showInfo)
          Positioned(
            bottom: 60,
            left: -100,
            child: BusInfoWindow(bus: widget.bus),
          ),
      ],
    );
  }
}
