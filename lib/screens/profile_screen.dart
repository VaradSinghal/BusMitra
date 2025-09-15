import 'package:busmitra/models/user_model.dart';
import 'package:busmitra/services/auth_service.dart';
import 'package:busmitra/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _userModel;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.user;
      
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _userModel = UserModel.fromMap(doc.data()!);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'User profile not found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'User not authenticated';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserProfile(UserModel updatedUser) async {
    try {
      await _firestore.collection('users').doc(updatedUser.uid).update(updatedUser.toMap());
      setState(() {
        _userModel = updatedUser;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppConstants.primaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  void _showEditProfileDialog() {
    if (_userModel == null) return;

    final nameController = TextEditingController(text: _userModel!.name);
    final phoneController = TextEditingController(text: _userModel!.phoneNumber ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedUser = _userModel!.copyWith(
                name: nameController.text.trim(),
                phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
              );
              await _updateUserProfile(updatedUser);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthService>(context, listen: false).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.accentColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _userModel != null ? _showEditProfileDialog : null,
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
            Text('Loading profile...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppConstants.errorColor),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppConstants.errorColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_userModel == null) {
      return const Center(
        child: Text('No user data available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildProfileInfo(),
          const SizedBox(height: 24),
          _buildPreferencesSection(),
          const SizedBox(height: 24),
          _buildAccountSection(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Profile Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: AppConstants.accentColor,
            backgroundImage: _userModel!.hasProfileImage 
                ? NetworkImage(_userModel!.profileImageUrl!)
                : null,
            child: _userModel!.hasProfileImage 
                ? null 
                : Text(
                    _userModel!.initials,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          
          // User Name
          Text(
            _userModel!.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstants.accentColor,
            ),
          ),
          const SizedBox(height: 8),
          
          // Email
          Text(
            _userModel!.email,
            style: const TextStyle(
              fontSize: 16,
              color: AppConstants.accentColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Member Since
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Member since ${_userModel!.formattedCreatedDate}',
              style: const TextStyle(
                fontSize: 12,
                color: AppConstants.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, 'Full Name', _userModel!.name),
            _buildInfoRow(Icons.email, 'Email', _userModel!.email),
            _buildInfoRow(Icons.phone, 'Phone', _userModel!.formattedPhoneNumber),
            _buildInfoRow(Icons.verified, 'Email Verified', 
                _userModel!.isEmailVerified ? 'Verified' : 'Not Verified'),
            _buildInfoRow(Icons.access_time, 'Last Login', _userModel!.formattedLastLogin),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppConstants.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppConstants.lightTextColor,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppConstants.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildPreferenceSwitch(
              'Notifications',
              'Receive notifications about bus arrivals',
              _userModel!.notificationsEnabled,
              (value) async {
                final updatedUser = _userModel!.copyWith(
                  preferences: {
                    ..._userModel!.preferences,
                    'notifications': value,
                  },
                );
                await _updateUserProfile(updatedUser);
              },
            ),
            _buildPreferenceSwitch(
              'Location Tracking',
              'Allow location tracking for better service',
              _userModel!.locationTrackingEnabled,
              (value) async {
                final updatedUser = _userModel!.copyWith(
                  preferences: {
                    ..._userModel!.preferences,
                    'locationTracking': value,
                  },
                );
                await _updateUserProfile(updatedUser);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceSwitch(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppConstants.lightTextColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppConstants.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildAccountAction(
              Icons.favorite,
              'Favorite Routes',
              'Manage your favorite bus routes',
              () {
                // TODO: Navigate to favorite routes screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Favorite routes feature coming soon')),
                );
              },
            ),
            _buildAccountAction(
              Icons.history,
              'Trip History',
              'View your past trips',
              () {
                // TODO: Navigate to trip history screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Trip history feature coming soon')),
                );
              },
            ),
            _buildAccountAction(
              Icons.help,
              'Help & Support',
              'Get help and contact support',
              () {
                // TODO: Navigate to help screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & support feature coming soon')),
                );
              },
            ),
            _buildAccountAction(
              Icons.logout,
              'Logout',
              'Sign out of your account',
              _showLogoutDialog,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountAction(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDestructive ? AppConstants.errorColor : AppConstants.primaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? AppConstants.errorColor : AppConstants.textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppConstants.lightTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppConstants.lightTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
