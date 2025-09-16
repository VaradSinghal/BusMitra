import 'package:busmitra/models/route_model.dart';
import 'package:busmitra/screens/bus_tracking_screen.dart';
import 'package:busmitra/services/database_service.dart';
import 'package:busmitra/utils/constants.dart';
import 'package:busmitra/widgets/route_card.dart';
import 'package:flutter/material.dart';
import 'package:busmitra/services/auth_service.dart';
import 'package:busmitra/screens/login_screen.dart';


class RouteSelectionScreen extends StatefulWidget {
  const RouteSelectionScreen({super.key});

  @override
  State<RouteSelectionScreen> createState() => _RouteSelectionScreenState();
}

class _RouteSelectionScreenState extends State<RouteSelectionScreen> {
  final DatabaseService _databaseService = DatabaseService();
  
  String _searchQuery = '';
  
  List<BusRoute> _applySearchFilter(List<BusRoute> routes) {
    if (_searchQuery.isEmpty) return routes;
    return routes.where((route) {
      final q = _searchQuery.toLowerCase();
      return route.name.toLowerCase().contains(q) ||
             route.startPoint.toLowerCase().contains(q) ||
             route.endPoint.toLowerCase().contains(q);
    }).toList();
  }

  void _navigateToBusTracking(BusRoute route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusTrackingScreen(route: route),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Route'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.accentColor,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: StreamBuilder<List<BusRoute>>(
            stream: _databaseService.getActiveRoutes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading active routes...'),
                    ],
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load active routes',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                );
              }

              final routes = _applySearchFilter(snapshot.data ?? []);
              if (routes.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.route, size: 64, color: AppConstants.lightTextColor),
                      SizedBox(height: 16),
                      Text(
                        'No active routes found',
                        style: TextStyle(fontSize: 18, color: AppConstants.lightTextColor),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  final route = routes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: StreamBuilder<int>(
                      stream: _databaseService.getBusCountForRoute(route.id),
                      builder: (context, countSnap) {
                        final count = countSnap.data ?? 0;
                        return RouteCard(
                          route: route,
                          activeBusCount: count,
                          isActive: count > 0,
                          onTap: () => _navigateToBusTracking(route),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search routes...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppConstants.backgroundColor,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await AuthService().signOut();
    } finally {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  // list rendering moved into stream builder above
}
