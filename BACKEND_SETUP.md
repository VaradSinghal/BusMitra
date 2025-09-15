# Backend Setup Guide for BusMitra

This guide helps you set up the Firebase backend for your BusMitra application.

## 🚀 Quick Setup with FlutterFire

### 1. Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### 2. Configure Firebase Project
```bash
flutterfire configure
```
This will:
- Generate `firebase_options.dart` with your project configuration
- Set up platform-specific configuration files
- Configure your Flutter app to use Firebase

### 3. Add Firebase Dependencies
Your `pubspec.yaml` should include:
```yaml
dependencies:
  firebase_core: ^2.4.0
  firebase_auth: ^4.2.0
  firebase_database: ^10.0.0
  cloud_firestore: ^4.3.0
```

## 🗄️ Firebase Realtime Database Structure

### Database Schema
```
busmitra-db/
├── routes/
│   ├── route_8B/
│   │   ├── id: "route_8B"
│   │   ├── name: "Route 8B: North Station to Airport"
│   │   ├── startPoint: "North Bus Station"
│   │   ├── endPoint: "International Airport"
│   │   ├── distance: 22.3
│   │   ├── estimatedTime: 60
│   │   ├── active: true
│   │   ├── createdAt: "2023-10-01T08:00:00Z"
│   │   ├── updatedAt: "2023-10-01T08:00:00Z"
│   │   └── stops/
│   │       ├── stop_1/
│   │       │   ├── id: "stop_1"
│   │       │   ├── name: "North Bus Station"
│   │       │   ├── latitude: 28.7041
│   │       │   ├── longitude: 77.1025
│   │       │   └── sequence: 1
│   │       └── stop_2/
│   │           ├── id: "stop_2"
│   │           ├── name: "Metro Station"
│   │           ├── latitude: 28.7010
│   │           ├── longitude: 77.1100
│   │           └── sequence: 2
│   └── route_27D/
│       └── ... (similar structure)
├── active_drivers/
│   ├── DRV001/
│   │   ├── accuracy: 13.65
│   │   ├── busNumber: "TN01AC1234"
│   │   ├── connectionStatus: "connected"
│   │   ├── driverId: "DRV001"
│   │   ├── driverName: "Rajesh Kumar"
│   │   ├── heading: 45.0
│   │   ├── heartbeat: 1757837600309
│   │   ├── isOnDuty: true
│   │   ├── isOnline: true
│   │   ├── lastSeen: 1757837597501
│   │   ├── latitude: 12.8222974
│   │   ├── longitude: 80.0271408
│   │   ├── routeId: "route_8B"
│   │   ├── routeName: "Route 8B: North Station to Airport"
│   │   ├── speed: 25.5
│   │   ├── timestamp: 1757837597501
│   │   └── updateCount: 15
│   └── DRV002/
│       └── ... (similar structure)
└── users/
    ├── user_uid_1/
    │   ├── uid: "user_uid_1"
    │   ├── email: "user@example.com"
    │   ├── name: "John Doe"
    │   ├── phoneNumber: "+1234567890"
    │   ├── createdAt: "2023-10-01T08:00:00Z"
    │   ├── lastLoginAt: "2023-10-15T10:30:00Z"
    │   ├── favoriteRoutes: ["route_8B", "route_27D"]
    │   ├── preferences/
    │   │   ├── notifications: true
    │   │   ├── locationTracking: true
    │   │   ├── language: "en"
    │   │   └── themeMode: "system"
    │   └── isEmailVerified: true
    └── user_uid_2/
        └── ... (similar structure)
```

## 🔐 Security Rules

### Realtime Database Rules
```json
{
  "rules": {
    "routes": {
      ".read": "auth != null",
      ".write": "auth != null && auth.token.admin == true"
    },
    "active_drivers": {
      ".read": "auth != null",
      ".write": "auth != null && auth.token.driver == true"
    },
    "users": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    }
  }
}
```

### Firestore Rules (if using Firestore for user data)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 📊 Sample Data Setup

### 1. Create Sample Routes
Use the Firebase Console or run this script to add sample routes:

```javascript
// Run this in Firebase Console > Realtime Database > Data
const sampleRoutes = {
  "route_8B": {
    "id": "route_8B",
    "name": "Route 8B: North Station to Airport",
    "startPoint": "North Bus Station",
    "endPoint": "International Airport",
    "distance": 22.3,
    "estimatedTime": 60,
    "active": true,
    "createdAt": "2023-10-01T08:00:00Z",
    "updatedAt": "2023-10-01T08:00:00Z",
    "stops": {
      "stop_1": {
        "id": "stop_1",
        "name": "North Bus Station",
        "latitude": 28.7041,
        "longitude": 77.1025,
        "sequence": 1
      },
      "stop_2": {
        "id": "stop_2",
        "name": "Metro Station",
        "latitude": 28.7010,
        "longitude": 77.1100,
        "sequence": 2
      },
      "stop_3": {
        "id": "stop_3",
        "name": "Business District",
        "latitude": 28.6980,
        "longitude": 77.1180,
        "sequence": 3
      },
      "stop_4": {
        "id": "stop_4",
        "name": "Convention Center",
        "latitude": 28.6950,
        "longitude": 77.1250,
        "sequence": 4
      },
      "stop_5": {
        "id": "stop_5",
        "name": "Hotel Zone",
        "latitude": 28.6920,
        "longitude": 77.1320,
        "sequence": 5
      },
      "stop_6": {
        "id": "stop_6",
        "name": "Airport Entrance",
        "latitude": 28.6890,
        "longitude": 77.1400,
        "sequence": 6
      },
      "stop_7": {
        "id": "stop_7",
        "name": "International Airport",
        "latitude": 28.6860,
        "longitude": 77.1480,
        "sequence": 7
      }
    }
  },
  "route_27D": {
    "id": "route_27D",
    "name": "Route 27D: Broadway to Velachery",
    "startPoint": "Broadway",
    "endPoint": "Velachery",
    "distance": 18.5,
    "estimatedTime": 45,
    "active": true,
    "createdAt": "2023-10-01T08:00:00Z",
    "updatedAt": "2023-10-01T08:00:00Z",
    "stops": {
      "stop_1": {
        "id": "stop_1",
        "name": "Broadway",
        "latitude": 12.8222974,
        "longitude": 80.0271408,
        "sequence": 1
      },
      "stop_2": {
        "id": "stop_2",
        "name": "Central Station",
        "latitude": 12.8200000,
        "longitude": 80.0300000,
        "sequence": 2
      },
      "stop_3": {
        "id": "stop_3",
        "name": "Velachery",
        "latitude": 12.8100000,
        "longitude": 80.0400000,
        "sequence": 3
      }
    }
  }
};

// Add to Firebase Realtime Database
```

### 2. Create Sample Active Drivers
```javascript
const sampleDrivers = {
  "DRV001": {
    "accuracy": 13.65,
    "busNumber": "TN01AC1234",
    "connectionStatus": "connected",
    "driverId": "DRV001",
    "driverName": "Rajesh Kumar",
    "heading": 45.0,
    "heartbeat": 1757837600309,
    "isOnDuty": true,
    "isOnline": true,
    "lastSeen": 1757837597501,
    "latitude": 28.7041,
    "longitude": 77.1025,
    "routeId": "route_8B",
    "routeName": "Route 8B: North Station to Airport",
    "speed": 25.5,
    "timestamp": 1757837597501,
    "updateCount": 15
  },
  "DRV002": {
    "accuracy": 13.65,
    "busNumber": "TN01AC5678",
    "connectionStatus": "connected",
    "driverId": "DRV002",
    "driverName": "Sunil Sharma",
    "heading": 0,
    "heartbeat": 1757837600309,
    "isOnDuty": true,
    "isOnline": true,
    "lastSeen": 1757837597501,
    "latitude": 12.8222974,
    "longitude": 80.0271408,
    "routeId": "route_27D",
    "routeName": "Route 27D: Broadway to Velachery",
    "speed": 0,
    "timestamp": 1757837597501,
    "updateCount": 15
  }
};
```

## 🔧 Driver App Integration

### For Driver Apps to Update Location:
```javascript
// Driver app should update location like this:
const updateDriverLocation = (driverId, locationData) => {
  const updates = {};
  updates[`/active_drivers/${driverId}/latitude`] = locationData.latitude;
  updates[`/active_drivers/${driverId}/longitude`] = locationData.longitude;
  updates[`/active_drivers/${driverId}/speed`] = locationData.speed;
  updates[`/active_drivers/${driverId}/heading`] = locationData.heading;
  updates[`/active_drivers/${driverId}/timestamp`] = Date.now();
  updates[`/active_drivers/${driverId}/updateCount`] = increment(1);
  updates[`/active_drivers/${driverId}/heartbeat`] = Date.now();
  
  return firebase.database().ref().update(updates);
};
```

## 📱 Testing the Setup

### 1. Test User Registration
- Register a new user in the app
- Check if user data is created in Firestore

### 2. Test Route Loading
- Check if routes are loaded from Realtime Database
- Verify route structure matches the schema

### 3. Test Bus Tracking
- Add sample driver data to `active_drivers`
- Verify bus locations appear on the map
- Test real-time updates

### 4. Test Security Rules
- Try accessing data without authentication
- Verify users can only access their own data

## 🚨 Troubleshooting

### Common Issues:

1. **Firebase not initialized**
   - Ensure `firebase_options.dart` is generated by FlutterFire CLI
   - Check if Firebase.initializeApp() is called in main()

2. **Permission denied errors**
   - Check Firebase Security Rules
   - Ensure user is authenticated
   - Verify user has proper permissions

3. **No data loading**
   - Check database structure matches the expected schema
   - Verify network connectivity
   - Check Firebase project configuration

4. **Real-time updates not working**
   - Ensure using Firebase Realtime Database (not Firestore)
   - Check if listeners are properly set up
   - Verify data is being written to the correct paths

## 📞 Support

For backend setup issues:
1. Check Firebase Console for errors
2. Verify security rules are properly configured
3. Test with Firebase Console to ensure data structure is correct
4. Check FlutterFire CLI configuration
