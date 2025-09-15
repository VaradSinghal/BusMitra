import 'package:busmitra/models/route_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class StopMarker extends StatelessWidget {
  final RouteStop stop;
  final bool isNearestStop;
  final bool isUpcomingStop;
  final VoidCallback? onTap;

  const StopMarker({
    super.key,
    required this.stop,
    this.isNearestStop = false,
    this.isUpcomingStop = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isNearestStop ? 40 : 30,
        height: isNearestStop ? 40 : 30,
        decoration: BoxDecoration(
          color: _getStopColor(isNearestStop, isUpcomingStop),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: isNearestStop ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: isNearestStop ? 8 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.location_on,
          color: Colors.white,
          size: isNearestStop ? 20 : 16,
        ),
      ),
    );
  }


  // Create a BitmapDescriptor for the stop marker
  static Future<BitmapDescriptor> createStopMarkerIcon({
    required RouteStop stop,
    bool isNearestStop = false,
    bool isUpcomingStop = false,
  }) async {
    // Create a custom marker icon based on stop status
    final Color statusColor = _getStopColor(isNearestStop, isUpcomingStop);
    
    // For now, return a default marker icon
    // In a real implementation, you might want to create a custom bitmap
    return BitmapDescriptor.defaultMarkerWithHue(
      _getHueFromColor(statusColor),
    );
  }

  static Color _getStopColor(bool isNearestStop, bool isUpcomingStop) {
    if (isNearestStop) {
      return Colors.blue;
    } else if (isUpcomingStop) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  // Convert Color to hue value for BitmapDescriptor
  static double _getHueFromColor(Color color) {
    if (color == Colors.blue) return BitmapDescriptor.hueBlue;
    if (color == Colors.green) return BitmapDescriptor.hueGreen;
    if (color == Colors.grey) return BitmapDescriptor.hueViolet;
    return BitmapDescriptor.hueBlue;
  }
}

// Stop info window widget
class StopInfoWindow extends StatelessWidget {
  final RouteStop stop;
  final bool isNearestStop;
  final double? distanceFromUser;
  final int? estimatedTime;

  const StopInfoWindow({
    super.key,
    required this.stop,
    this.isNearestStop = false,
    this.distanceFromUser,
    this.estimatedTime,
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
          // Stop name and sequence
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: isNearestStop ? Colors.blue : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stop.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isNearestStop ? Colors.blue : Colors.black,
                  ),
                ),
              ),
              if (isNearestStop)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'NEAREST',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Stop sequence
          Row(
            children: [
              const Icon(Icons.format_list_numbered, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Stop ${stop.sequence}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          
          // Distance from user (if provided)
          if (distanceFromUser != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.straighten, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  _formatDistance(distanceFromUser!),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
          
          // Estimated time (if provided)
          if (estimatedTime != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  _formatTime(estimatedTime!),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
          
          // Coordinates
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.my_location, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '${stop.latitude.toStringAsFixed(6)}, ${stop.longitude.toStringAsFixed(6)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m away';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km away';
    }
  }

  String _formatTime(int minutes) {
    if (minutes < 60) {
      return '~$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '~$hours hr';
      } else {
        return '~$hours hr $remainingMinutes min';
      }
    }
  }
}

// Stop marker with info window
class StopMarkerWithInfo extends StatefulWidget {
  final RouteStop stop;
  final bool isNearestStop;
  final bool isUpcomingStop;
  final double? distanceFromUser;
  final int? estimatedTime;
  final VoidCallback? onTap;

  const StopMarkerWithInfo({
    super.key,
    required this.stop,
    this.isNearestStop = false,
    this.isUpcomingStop = false,
    this.distanceFromUser,
    this.estimatedTime,
    this.onTap,
  });

  @override
  State<StopMarkerWithInfo> createState() => _StopMarkerWithInfoState();
}

class _StopMarkerWithInfoState extends State<StopMarkerWithInfo> {
  bool _showInfo = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Stop marker
        StopMarker(
          stop: widget.stop,
          isNearestStop: widget.isNearestStop,
          isUpcomingStop: widget.isUpcomingStop,
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
            bottom: 50,
            left: -100,
            child: StopInfoWindow(
              stop: widget.stop,
              isNearestStop: widget.isNearestStop,
              distanceFromUser: widget.distanceFromUser,
              estimatedTime: widget.estimatedTime,
            ),
          ),
      ],
    );
  }
}
