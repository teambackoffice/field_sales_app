import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:location_tracker_app/service/employee_location_service.dart';

class LocationController extends ChangeNotifier {
  static const MethodChannel _channel = MethodChannel('location_tracking');
  final EmployeeLocationService _service = EmployeeLocationService();
  static const _storage = FlutterSecureStorage();

  bool isLoading = false;
  bool isTracking = false;
  String? error;
  String? lastResult;
  int trackingInterval = 60; // seconds (1 minute)

  // Batch sending configuration
  bool enableBatchSending = false;
  int batchSize = 10;
  final List<LocationEntry> _pendingEntries = [];

  LocationController() {
    _setupMethodCallHandler();
    _loadTrackingState(); // Load saved state when app starts
    print("🚀 LocationController initialized");
  }

  // Save tracking state to persistent storage
  Future<void> _saveTrackingState() async {
    try {
      await _storage.write(key: 'is_tracking', value: isTracking.toString());
      print("💾 Tracking state saved: $isTracking");
    } catch (e) {
      print("❌ Failed to save tracking state: $e");
    }
  }

  // Load tracking state from persistent storage
  Future<void> _loadTrackingState() async {
    try {
      String? savedState = await _storage.read(key: 'is_tracking');
      if (savedState != null) {
        isTracking = savedState == 'true';
        print("📱 Loaded tracking state: $isTracking");

        // If the app was tracking when closed, resume tracking
        if (isTracking) {
          print("🔄 Resuming background tracking...");
          await _resumeTracking();
        }

        notifyListeners();
      }
    } catch (e) {
      print("❌ Failed to load tracking state: $e");
    }
  }

  // Resume tracking without user interaction
  Future<void> _resumeTracking() async {
    try {
      final bool started = await _channel.invokeMethod(
        'startLocationTracking',
        {'intervalSeconds': trackingInterval},
      );

      if (started) {
        lastResult = '🔄 Tracking resumed from background';
        print("✅ Background tracking resumed successfully");
      } else {
        print("❌ Failed to resume background tracking");
        isTracking = false;
        await _saveTrackingState();
      }
    } catch (e) {
      print("❌ Error resuming tracking: $e");
      isTracking = false;
      await _saveTrackingState();
    }
  }

  void _setupMethodCallHandler() {
    print("🔧 Setting up MethodChannel handler");
    _channel.setMethodCallHandler((MethodCall call) async {
      print("📱 Received method call: ${call.method}");
      print("📱 Call arguments: ${call.arguments}");

      switch (call.method) {
        case 'onLocationUpdate':
          print("📍 AUTOMATIC LOCATION UPDATE RECEIVED!");
          await _handleLocationUpdate(call.arguments);
          break;
        case 'onTrackingError':
          print("❌ Tracking error received: ${call.arguments}");
          _handleTrackingError(call.arguments);
          break;
        default:
          print("❓ Unknown method: ${call.method}");
      }
    });
  }

  Future<void> _handleLocationUpdate(Map<dynamic, dynamic> locationData) async {
    print("🎯 _handleLocationUpdate called with: $locationData");

    try {
      // Validate location data first
      if (!locationData.containsKey('latitude') ||
          !locationData.containsKey('longitude')) {
        throw Exception('Invalid location data: missing latitude or longitude');
      }

      double? latitude = locationData['latitude']?.toDouble();
      double? longitude = locationData['longitude']?.toDouble();

      if (latitude == null || longitude == null) {
        throw Exception('Invalid location data: latitude or longitude is null');
      }

      print("📍 Processing location: $latitude, $longitude");

      final now = DateTime.now();
      final date = DateFormat('yyyy-MM-dd').format(now);
      final time = DateFormat('HH:mm:ss').format(now);

      print("📅 Date: $date, Time: $time");
      print("🚀 SENDING TO API AUTOMATICALLY with Track entry type...");

      // Send with "Track" entry type for automatic updates
      await _service.sendLocation(
        latitude: latitude,
        longitude: longitude,
        date: date,
        time: time,
        entryType: "Track", // Automatic tracking entry type
      );

      lastResult = '✅ AUTO-SENT: $latitude, $longitude at $time';
      error = null;
      print("✅ SUCCESS: $lastResult");
      notifyListeners();
    } catch (e, stackTrace) {
      String errorMessage = e.toString();
      error = '❌ Auto-send failed: $errorMessage';
      print("❌ DETAILED ERROR: $e");
      print("📍 Stack trace: $stackTrace");
      notifyListeners();

      // Detailed error handling
      if (errorMessage.contains('credentials')) {
        error = '❌ Missing login credentials (sid/sales_person_id)';
      } else if (errorMessage.contains('Failed to send location: 401')) {
        error = '❌ Authentication failed - please login again';
      } else if (errorMessage.contains('Failed to send location: 403')) {
        error = '❌ Access denied - check permissions';
      } else if (errorMessage.contains('Failed to send location: 500')) {
        error = '❌ Server error - try again later';
      } else if (errorMessage.contains('SocketException') ||
          errorMessage.contains('NetworkException')) {
        error = '❌ Network error - check internet connection';
      }
      notifyListeners();
    }
  }

  void _handleTrackingError(String errorMessage) {
    error = "📱 Tracking error: $errorMessage";
    print("❌ Tracking error: $errorMessage");
    notifyListeners();
  }

  Future<bool> requestPermissions() async {
    try {
      print("🔐 Requesting permissions...");
      final bool hasBackgroundPermission = await _channel.invokeMethod(
        'requestBackgroundPermission',
      );

      if (!hasBackgroundPermission) {
        error = 'Background location permission required';
        print("❌ Permission denied");
        notifyListeners();
        return false;
      }

      print("✅ Permissions granted");
      return true;
    } catch (e) {
      error = 'Permission error: $e';
      print("❌ Permission error: $e");
      notifyListeners();
      return false;
    }
  }

  Future<void> startTracking() async {
    if (isTracking) {
      print("⚠️ Already tracking");
      return;
    }

    print("🚀 Starting tracking with Check In...");
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final bool hasPermissions = await requestPermissions();
      if (!hasPermissions) {
        isLoading = false;
        notifyListeners();
        return;
      }

      // First send Check In entry
      print("📍 Sending Check In entry...");
      final Map<dynamic, dynamic>? locationData = await _channel.invokeMethod(
        'getCurrentLocation',
      );

      if (locationData != null) {
        double latitude = locationData['latitude'];
        double longitude = locationData['longitude'];

        final now = DateTime.now();
        final date = DateFormat('yyyy-MM-dd').format(now);
        final time = DateFormat('HH:mm:ss').format(now);

        // Send Check In entry first
        await _service.sendLocation(
          latitude: latitude,
          longitude: longitude,
          date: date,
          time: time,
          entryType: "Check In",
        );

        print("✅ Check In entry sent successfully");
      }

      // Then start continuous tracking
      print("📡 Starting continuous tracking...");
      final bool started = await _channel.invokeMethod(
        'startLocationTracking',
        {'intervalSeconds': trackingInterval},
      );

      if (started) {
        isTracking = true;
        await _saveTrackingState(); // Save state persistently
        lastResult =
            '🟢 Auto-tracking started - will send every ${trackingInterval}s';
        _pendingEntries.clear();
        print("✅ Tracking started successfully");
      } else {
        error = '❌ Failed to start native tracking';
        print("❌ Failed to start tracking");
      }
    } catch (e) {
      error = '❌ Start tracking error: $e';
      print("❌ Start tracking error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> stopTracking() async {
    if (!isTracking) return;

    print("🛑 Stopping tracking with Check Out...");
    isLoading = true;
    notifyListeners();

    try {
      // First send Check Out entry
      print("📍 Sending Check Out entry...");
      final Map<dynamic, dynamic>? locationData = await _channel.invokeMethod(
        'getCurrentLocation',
      );

      if (locationData != null) {
        double latitude = locationData['latitude'];
        double longitude = locationData['longitude'];

        final now = DateTime.now();
        final date = DateFormat('yyyy-MM-dd').format(now);
        final time = DateFormat('HH:mm:ss').format(now);

        // Send Check Out entry
        await _service.sendLocation(
          latitude: latitude,
          longitude: longitude,
          date: date,
          time: time,
          entryType: "Check Out",
        );

        print("✅ Check Out entry sent successfully");
      }

      // Then stop continuous tracking
      final bool stopped = await _channel.invokeMethod('stopLocationTracking');

      if (stopped) {
        isTracking = false;
        await _saveTrackingState(); // Save state persistently
        lastResult = '🔴 Auto-tracking stopped';
        print("✅ Tracking stopped successfully");
      } else {
        error = '❌ Failed to stop tracking';
        print("❌ Failed to stop tracking");
      }
    } catch (e) {
      error = '❌ Stop tracking error: $e';
      print("❌ Stop tracking error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateTrackingInterval(int intervalSeconds) async {
    trackingInterval = intervalSeconds;
    print("⏱️ Updating interval to $intervalSeconds seconds");

    if (isTracking) {
      try {
        await _channel.invokeMethod('updateInterval', {
          'intervalSeconds': intervalSeconds,
        });
        lastResult = 'Interval updated to $intervalSeconds seconds';
        notifyListeners();
      } catch (e) {
        error = 'Failed to update interval: $e';
        notifyListeners();
      }
    }
  }

  // Manual location post (Send Now button) - KEPT FOR YOUR UI
  Future<void> postLocation() async {
    print("📍 Manual location request...");
    isLoading = true;
    error = null;
    lastResult = null;
    notifyListeners();

    try {
      final Map<dynamic, dynamic>? locationData = await _channel.invokeMethod(
        'getCurrentLocation',
      );

      if (locationData != null) {
        double latitude = locationData['latitude'];
        double longitude = locationData['longitude'];

        final now = DateTime.now();
        final date = DateFormat('yyyy-MM-dd').format(now);
        final time = DateFormat('HH:mm:ss').format(now);

        // Send with "Track" entry type for manual sends
        await _service.sendLocation(
          latitude: latitude,
          longitude: longitude,
          date: date,
          time: time,
          entryType: "Track", // Manual sends are also "Track" type
        );

        lastResult = '✅ MANUAL: Location sent successfully';
        print("✅ Manual location sent successfully");
      } else {
        error = '❌ Failed to get current location';
        print("❌ Failed to get current location");
      }
    } catch (e) {
      error = '❌ Manual location error: $e';
      print("❌ Manual location error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // Batch methods (KEPT FOR YOUR UI COMPATIBILITY)
  Future<void> sendPendingEntries() async {
    print("📦 Send pending entries (currently disabled)");
    lastResult = 'Batch sending disabled for debugging';
    notifyListeners();
  }

  void toggleBatchSending(bool enabled) {
    enableBatchSending = false;
    print("📦 Batch sending toggle attempted - keeping disabled for debugging");
    notifyListeners();
  }

  void updateBatchSize(int newSize) {
    batchSize = newSize.clamp(1, 50);
    print("📦 Batch size updated to $batchSize (currently disabled)");
    notifyListeners();
  }

  // Getters for UI (KEPT FOR YOUR UI)
  int get pendingEntriesCount => _pendingEntries.length;
  bool get hasPendingEntries => _pendingEntries.isNotEmpty;

  // KEPT FOR YOUR UI COMPATIBILITY
  Future<void> checkStoredCredentials() async {
    try {
      const storage = FlutterSecureStorage();
      String? sid = await storage.read(key: 'sid');
      String? salesPersonId = await storage.read(key: 'sales_person_id');

      print("🔐 CREDENTIAL CHECK:");
      print(
        "   SID: ${sid != null ? 'EXISTS (${sid.length} chars)' : 'MISSING'}",
      );
      print("   Sales Person ID: ${salesPersonId ?? 'MISSING'}");

      if (sid == null || salesPersonId == null) {
        throw Exception('Missing stored credentials - please login again');
      }
    } catch (e) {
      print("❌ Credential check failed: $e");
      rethrow;
    }
  }
}
