import 'package:busmitra/models/route_model.dart';
import 'package:busmitra/utils/constants.dart';
import 'package:flutter/material.dart';

class RouteCard extends StatelessWidget {
  final BusRoute route;
  final int activeBusCount;
  final bool isActive;
  final VoidCallback? onTap;

  const RouteCard({
    super.key,
    required this.route,
    required this.activeBusCount,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isActive ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? AppConstants.primaryColor : AppConstants.lightTextColor.withOpacity(0.3),
          width: isActive ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isActive ? AppConstants.primaryColor : AppConstants.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${route.startPoint} → ${route.endPoint}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppConstants.lightTextColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: AppConstants.accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Route details
              Row(
                children: [
                  _buildInfoChip(
                    Icons.straighten,
                    '${route.distance.toStringAsFixed(1)} km',
                    AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.access_time,
                    '${route.estimatedTime} min',
                    AppConstants.secondaryColor,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.location_on,
                    '${route.stops.length} stops',
                    AppConstants.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Active buses info
              Row(
                children: [
                  Icon(
                    Icons.directions_bus,
                    size: 16,
                    color: activeBusCount > 0 ? AppConstants.primaryColor : AppConstants.lightTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    activeBusCount > 0 
                        ? '$activeBusCount active bus${activeBusCount > 1 ? 'es' : ''}'
                        : 'No active buses',
                    style: TextStyle(
                      fontSize: 12,
                      color: activeBusCount > 0 ? AppConstants.primaryColor : AppConstants.lightTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppConstants.lightTextColor,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
