import 'package:busmitra/models/bus_model.dart';
import 'package:busmitra/models/route_model.dart';
import 'package:busmitra/screens/bus_tracking_screen.dart';
import 'package:busmitra/services/auth_service.dart';
import 'package:busmitra/services/database_service.dart';
import 'package:busmitra/services/location_service.dart';
import 'package:busmitra/utils/constants.dart';
import 'package:busmitra/widgets/route_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final LocationService _locationService = LocationService();
  
  List<BusRoute> _routes = [];
  List<BusRoute> _activeRoutes = [];
  List<Bus> _allActiveBuses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  Position? _userLocation;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get user location
      await _getUserLocation();

      // Load routes and active buses
      await _loadRoutes();
      _listenToActiveBuses();
      _listenToActiveRoutes();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load dashboard: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _userLocation = position;
        });
      }
    } catch (e) {
      print('Error getting user location: $e');
    }
  }

  Future<void> _loadRoutes() async {
    try {
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

  void _listenToActiveBuses() {
    _databaseService.getAllActiveBuses().listen((buses) {
      setState(() {
        _allActiveBuses = buses;
      });
    });
  }

  void _listenToActiveRoutes() {
    _databaseService.getActiveRoutes().listen((activeRoutes) {
      setState(() {
        _activeRoutes = activeRoutes;
      });
    });
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

  int _getActiveBusCount(String routeId) {
    return _allActiveBuses.where((bus) => bus.routeId == routeId).length;
  }

  void _navigateToBusTracking(BusRoute route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusTrackingScreen(
          route: route,
          userLocation: _userLocation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BusMitra'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.accentColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeDashboard,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
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
              onPressed: _initializeDashboard,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        _buildActiveRoutesSection(),
        Expanded(
          child: _buildRoutesList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to BusMitra',
            style: TextStyle(
              color: AppConstants.accentColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userLocation != null 
                ? 'Location: ${_userLocation!.latitude.toStringAsFixed(4)}, ${_userLocation!.longitude.toStringAsFixed(4)}'
                : 'Location not available',
            style: const TextStyle(
              color: AppConstants.accentColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                'Active Routes',
                _activeRoutes.length.toString(),
                Icons.route,
                Colors.green,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Active Buses',
                _allActiveBuses.length.toString(),
                Icons.directions_bus,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppConstants.accentColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppConstants.accentColor, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppConstants.accentColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppConstants.accentColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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

  Widget _buildActiveRoutesSection() {
    if (_activeRoutes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Routes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textColor,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _activeRoutes.length,
              itemBuilder: (context, index) {
                final route = _activeRoutes[index];
                final busCount = _getActiveBusCount(route.id);
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  child: RouteCard(
                    route: route,
                    activeBusCount: busCount,
                    onTap: () => _navigateToBusTracking(route),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
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
        final busCount = _getActiveBusCount(route.id);
        final isActive = _activeRoutes.any((activeRoute) => activeRoute.id == route.id);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: RouteCard(
            route: route,
            activeBusCount: busCount,
            isActive: isActive,
            onTap: () => _navigateToBusTracking(route),
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthService>(context, listen: false).signOut();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
