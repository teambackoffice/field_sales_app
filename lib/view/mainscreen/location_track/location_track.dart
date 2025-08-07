import 'package:flutter/material.dart';
import 'package:location_tracker_app/controller/employee_location_controller.dart';
import 'package:location_tracker_app/view/mainscreen/location_track/customer_visit_log.dart';
import 'package:provider/provider.dart';

class LocationTrackingPage extends StatefulWidget {
  const LocationTrackingPage({super.key});

  @override
  _LocationTrackingPageState createState() => _LocationTrackingPageState();
}

class _LocationTrackingPageState extends State<LocationTrackingPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late LocationController _locationController;

  @override
  void initState() {
    super.initState();
    _locationController = Provider.of<LocationController>(
      context,
      listen: false,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _startTracking() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(children: [SizedBox(width: 8), Text("Check - In ?")]),
          content: Text(
            " Are you sure you want to check - in?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _locationController.startTracking();
                if (_locationController.isTracking) {
                  _pulseController.repeat(reverse: true);
                  _rotationController.repeat();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Yes, Check - In",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _stopTracking() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(children: [SizedBox(width: 8), Text("Check - Out ?")]),
          content: Text(
            " Are you sure you want to check - out?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _locationController.stopTracking();
                _pulseController.stop();
                _rotationController.stop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Yes, Check - Out",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog() {
    int selectedInterval = _locationController.trackingInterval;
    bool batchEnabled = _locationController.enableBatchSending;
    int batchSize = _locationController.batchSize;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Automatic Tracking Settings"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Interval Setting
                    Text(
                      "Auto Update Interval:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    DropdownButton<int>(
                      value: selectedInterval,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(value: 30, child: Text("30 seconds")),
                        DropdownMenuItem(value: 60, child: Text("1 minute")),
                        DropdownMenuItem(value: 120, child: Text("2 minutes")),
                        DropdownMenuItem(value: 300, child: Text("5 minutes")),
                        DropdownMenuItem(value: 600, child: Text("10 minutes")),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedInterval = value!;
                        });
                      },
                    ),

                    SizedBox(height: 20),
                    Divider(),

                    // Batch Settings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Batch Sending:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Switch(
                          value: batchEnabled,
                          onChanged: (value) {
                            setDialogState(() {
                              batchEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),

                    if (batchEnabled) ...[
                      SizedBox(height: 10),
                      Text(
                        "Batch Size:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      DropdownButton<int>(
                        value: batchSize,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: 5,
                            child: Text("5 locations per batch"),
                          ),
                          DropdownMenuItem(
                            value: 10,
                            child: Text("10 locations per batch"),
                          ),
                          DropdownMenuItem(
                            value: 15,
                            child: Text("15 locations per batch"),
                          ),
                          DropdownMenuItem(
                            value: 20,
                            child: Text("20 locations per batch"),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            batchSize = value!;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Batch mode reduces network requests and saves battery by sending multiple locations at once.",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ] else ...[
                      SizedBox(height: 10),
                      Text(
                        "Each location will be sent immediately to the server every $selectedInterval seconds.",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _locationController.updateTrackingInterval(
                      selectedInterval,
                    );
                    _locationController.toggleBatchSending(batchEnabled);
                    _locationController.updateBatchSize(batchSize);
                    Navigator.pop(context);
                  },
                  child: Text("Apply"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationController>(
      builder: (context, controller, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: controller.isTracking
                    ? [Color(0xFF667eea), Color(0xFF764ba2)]
                    : [Color(0xFF74b9ff), Color(0xFF0984e3)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(controller),
                  SizedBox(height: 100),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          SizedBox(height: 20), // Add some top spacing
                          // Animated tracking indicator
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              if (controller.isTracking)
                                AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _pulseAnimation.value,
                                      child: Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.9),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  controller.isTracking
                                      ? Icons.gps_fixed
                                      : Icons.gps_not_fixed,
                                  size: 50,
                                  color: controller.isTracking
                                      ? Color(0xFF00b894)
                                      : Color(0xFF636e72),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 100),

                          // Status container
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              controller.isTracking
                                  ? "You are Check - In"
                                  : " You are Check - Out",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: 20),

                          // Tracking details
                          if (controller.isTracking)
                            Column(
                              children: [
                                if (controller.hasPendingEntries) ...[
                                  SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.orange.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.queue,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "${controller.pendingEntriesCount} pending",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () =>
                                              controller.sendPendingEntries(),
                                          child: Icon(
                                            Icons.send,
                                            color: Colors.white70,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),

                          SizedBox(height: 20),

                          // Status messages
                          if (controller.lastResult != null)
                            if (controller.error != null) ...[
                              SizedBox(height: 10),
                            ],

                          SizedBox(height: 40),

                          // Main tracking button
                          GestureDetector(
                            onTap: controller.isLoading
                                ? null
                                : (controller.isTracking
                                      ? _stopTracking
                                      : _startTracking),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              width: 280,
                              height: 65,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: controller.isTracking
                                      ? [Color(0xFFff7675), Color(0xFFd63031)]
                                      : [Color(0xFF00b894), Color(0xFF00a085)],
                                ),
                                borderRadius: BorderRadius.circular(35),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (controller.isTracking
                                                ? Color(0xFFff7675)
                                                : Color(0xFF00b894))
                                            .withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (controller.isLoading)
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  else
                                    Icon(
                                      controller.isTracking
                                          ? Icons.stop
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  SizedBox(width: 12),
                                  Text(
                                    controller.isLoading
                                        ? 'Please wait...'
                                        : (controller.isTracking
                                              ? 'Check - Out'
                                              : 'Check - In'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 30),

                          // Action buttons row

                          // Add bottom spacing for scrolling
                          SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(LocationController controller) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF764BA2), Color(0xFF667EEA)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF764BA2).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employee Attendance',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              switch (value) {
                case 'visit_log':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerVisitLogger(),
                    ),
                  );
                  break;
                case 'send_pending':
                  controller.sendPendingEntries();
                  break;
                case 'clear_error':
                  controller.error = null;
                  controller.notifyListeners();
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 'visit_log',
                  child: Row(
                    children: [
                      Icon(Icons.list_alt, size: 20),
                      SizedBox(width: 8),
                      Text('Customer Visit Log'),
                    ],
                  ),
                ),
                if (controller.hasPendingEntries)
                  PopupMenuItem(
                    value: 'send_pending',
                    child: Row(
                      children: [
                        Icon(Icons.send, size: 20, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Send Pending (${controller.pendingEntriesCount})',
                        ),
                      ],
                    ),
                  ),
                if (controller.error != null)
                  PopupMenuItem(
                    value: 'clear_error',
                    child: Row(
                      children: [
                        Icon(Icons.clear, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Clear Error'),
                      ],
                    ),
                  ),
              ];
            },
          ),
        ],
      ),
    );
  }
}
