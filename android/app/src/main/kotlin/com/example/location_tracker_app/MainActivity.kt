package com.example.location_tracker_app

import android.Manifest
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    companion object {
        private const val CHANNEL = "location_tracking"
        private const val PERMISSION_REQUEST_CODE = 123
    }

    private var pendingResult: MethodChannel.Result? = null
    private var locationService: LocationTrackingService? = null
    private var isServiceBound = false
    private var methodChannel: MethodChannel? = null

    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            val binder = service as LocationTrackingService.LocationBinder
            locationService = binder.getService()
            locationService?.setMethodChannel(methodChannel)
            isServiceBound = true
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            isServiceBound = false
            locationService = null
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            onMethodCall(call, result)
        }
        
        // Bind to the service
        val serviceIntent = Intent(this, LocationTrackingService::class.java)
        bindService(serviceIntent, serviceConnection, Context.BIND_AUTO_CREATE)
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestBackgroundPermission" -> requestBackgroundPermission(result)
            "startLocationTracking" -> {
                val intervalSeconds = call.argument<Int>("intervalSeconds") ?: 60
                startLocationTracking(intervalSeconds, result)
            }
            "stopLocationTracking" -> stopLocationTracking(result)
            "updateInterval" -> {
                val newInterval = call.argument<Int>("intervalSeconds") ?: 60
                updateInterval(newInterval, result)
            }
            "getCurrentLocation" -> getCurrentLocation(result)
            else -> result.notImplemented()
        }
    }

    private fun requestBackgroundPermission(result: MethodChannel.Result) {
        pendingResult = result
        
        if (hasLocationPermissions()) {
            result.success(true)
            return
        }

        val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION,
                Manifest.permission.ACCESS_BACKGROUND_LOCATION
            )
        } else {
            arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION
            )
        }

        ActivityCompat.requestPermissions(this, permissions, PERMISSION_REQUEST_CODE)
    }

    private fun hasLocationPermissions(): Boolean {
        val fineLocation = ContextCompat.checkSelfPermission(this, 
            Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        val coarseLocation = ContextCompat.checkSelfPermission(this, 
            Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
        
        val backgroundLocation = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ContextCompat.checkSelfPermission(this, 
                Manifest.permission.ACCESS_BACKGROUND_LOCATION) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
        
        return fineLocation && coarseLocation && backgroundLocation
    }

    private fun startLocationTracking(intervalSeconds: Int, result: MethodChannel.Result) {
        if (!hasLocationPermissions()) {
            result.success(false)
            return
        }

        if (!isServiceBound || locationService == null) {
            result.success(false)
            return
        }

        val started = locationService!!.startTracking((intervalSeconds * 1000).toLong())
        result.success(started)
    }

    private fun stopLocationTracking(result: MethodChannel.Result) {
        if (!isServiceBound || locationService == null) {
            result.success(false)
            return
        }

        val stopped = locationService!!.stopTracking()
        result.success(stopped)
    }

    private fun updateInterval(intervalSeconds: Int, result: MethodChannel.Result) {
        if (!isServiceBound || locationService == null) {
            result.success(false)
            return
        }

        locationService!!.updateInterval((intervalSeconds * 1000).toLong())
        result.success(true)
    }

    private fun getCurrentLocation(result: MethodChannel.Result) {
        if (!hasLocationPermissions()) {
            result.error("PERMISSION_DENIED", "Location permissions not granted", null)
            return
        }

        if (!isServiceBound || locationService == null) {
            result.error("SERVICE_UNAVAILABLE", "Location service not available", null)
            return
        }

        locationService!!.getCurrentLocation(result)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == PERMISSION_REQUEST_CODE && pendingResult != null) {
            val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            
            if (!allGranted && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.fromParts("package", packageName, null)
                }
                startActivity(intent)
            }
            
            pendingResult?.success(allGranted)
            pendingResult = null
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (isServiceBound) {
            unbindService(serviceConnection)
            isServiceBound = false
        }
    }
}