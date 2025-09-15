import 'package:busmitra/models/route_model.dart';
import 'package:busmitra/screens/bus_tracking_screen.dart';
import 'package:busmitra/services/database_service.dart';
import 'package:busmitra/utils/constants.dart';
import 'package:busmitra/widgets/route_card.dart';
import 'package:flutter/material.dart';


class RouteSelectionScreen extends StatefulWidget {
  const RouteSelectionScreen({super.key});

  @override
  State<RouteSelectionScreen> createState() => _RouteSelectionScreenState();
}

class _RouteSelectionScreenState extends State<RouteSelectionScreen> {
  final DatabaseService _databaseService = DatabaseService();
  
  List<BusRoute> _routes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final routes = await _databaseService.getRoutes();
      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load routes: $e';
        _isLoading = false;
      });
    }
  }

  List<BusRoute> get _filteredRoutes {
    if (_searchQuery.isEmpty) {
      return _routes;
    }
    
    return _routes.where((route) {
      return route.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             route.startPoint.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             route.endPoint.toLowerCase().contains(_searchQuery.toLowerCase());
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
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading routes...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRoutes,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _buildRoutesList(),
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

  Widget _buildRoutesList() {
    if (_filteredRoutes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.route, size: 64, color: AppConstants.lightTextColor),
            const SizedBox(height: 16),
            Text(
              'No routes found',
              style: TextStyle(fontSize: 18, color: AppConstants.lightTextColor),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredRoutes.length,
      itemBuilder: (context, index) {
        final route = _filteredRoutes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: RouteCard(
            route: route,
            activeBusCount: 0, // This screen doesn't show active bus count
            onTap: () => _navigateToBusTracking(route),
          ),
        );
      },
    );
  }
}
