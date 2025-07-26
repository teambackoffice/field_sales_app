import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class LocationTrackingPage extends StatefulWidget {
  @override
  _LocationTrackingPageState createState() => _LocationTrackingPageState();
}

class _LocationTrackingPageState extends State<LocationTrackingPage> 
    with TickerProviderStateMixin {
  bool _isTracking = false;
  String _trackingStatus = "Ready to track";
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
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
    setState(() {
      _isTracking = true;
      _trackingStatus = "Tracking your location";
    });
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    print("Location tracking started");
  }

  void _stopTracking() {
    setState(() {
      _isTracking = false;
      _trackingStatus = "Tracking paused";
    });
    _pulseController.stop();
    _rotationController.stop();
    print("Location tracking stopped");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isTracking 
                ? [Color(0xFF667eea), Color(0xFF764ba2)]
                : [Color(0xFF74b9ff), Color(0xFF0984e3)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Location Tracker',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                   
                  ],
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated tracking indicator
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer pulsing ring
                          if (_isTracking)
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
                                        color: Colors.white.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          
                          // Rotating outer circle
                          if (_isTracking)
                            AnimatedBuilder(
                              animation: _rotationAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotationAnimation.value,
                                  child: Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 5,
                                          left: 75,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          
                          // Main circle
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
                              _isTracking ? Icons.gps_fixed : Icons.gps_not_fixed,
                              size: 50,
                              color: _isTracking 
                                  ? Color(0xFF00b894) 
                                  : Color(0xFF636e72),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 40),
                      
                      // Status text with glassmorphism effect
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _trackingStatus,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 60),
                      
                      // Modern toggle button
                      GestureDetector(
                        onTap: _isTracking ? _stopTracking : _startTracking,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: 280,
                          height: 65,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isTracking 
                                  ? [Color(0xFFff7675), Color(0xFFd63031)]
                                  : [Color(0xFF00b894), Color(0xFF00a085)],
                            ),
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: (_isTracking 
                                    ? Color(0xFFff7675) 
                                    : Color(0xFF00b894)).withOpacity(0.4),
                                blurRadius: 15,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isTracking ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Text(
                                _isTracking ? 'Stop Tracking' : 'Start Tracking',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 40),
                      
                      // Enhanced tracking info card
                      if (_isTracking)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              padding: EdgeInsets.all(24),
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Tracking Details',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildInfoItem(Icons.timer, 'Duration', '00:05:23'),
                                      _buildInfoItem(Icons.update, 'Updated', 'Just now'),
                                      _buildInfoItem(Icons.my_location, 'Accuracy', 'High'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 18,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}