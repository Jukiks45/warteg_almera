import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../services/notification_service.dart';

class LocationController extends GetxController {
  // -----------------------
  // Original state
  // -----------------------
  var isLoading = false.obs;
  var currentPosition = Rxn<Position>();
  var currentAddress = ''.obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;

  final mapController = MapController();
  final supabase = Supabase.instance.client;
  StreamSubscription<Position>? _positionStreamSubscription;

  var currentLatLng = Rxn<LatLng>();
  var locationMode = 'gps'.obs;
  var currentAccuracyText = ''.obs;

  // markers & polyline
  var markers = <Marker>[].obs;
  var polylines = <Polyline>[].obs;

  // -----------------------
  // Add-on: warteg & distance
  // -----------------------
  final targetLocation = Rxn<LatLng>();
  final distanceToTargetMeters = 0.0.obs;

  DateTime? _lastDistanceCalcAt;
  final int _distanceMinIntervalMillis = 500;
  bool _arrivalNotified = false;

  @override
  void onInit() {
    super.onInit();
    currentAccuracyText.value = 'GPS (Akurasi Terbaik)';

    // Jika warteg cuma 1 dan ingin otomatis set saat buka halaman:
    setHardcodedWarteg();

    getCurrentLocation();
    startLocationTracking();
  }

  @override
  void onClose() {
    _positionStreamSubscription?.cancel();
    super.onClose();
  }

  // -----------------------
  // Realtime tracking user
  // -----------------------
  void startLocationTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('⚠️ Location service not enabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('⚠️ Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('⚠️ Location permission denied forever');
        return;
      }
      print('🎯 Starting location tracking with mode: ${locationMode.value}');

      final locationSettings = _getLocationSettings();

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) async {
        debugPrint(
            '📍 Location updated: ${position.latitude}, ${position.longitude}');
        // lightweight updates
        currentPosition.value = position;
        currentLatLng.value = LatLng(position.latitude, position.longitude);

        // distance (throttled)
        _computeDistanceToTarget(position);

        // fetch route (OSRM) - non-blocking
        fetchRouteFromOSRM(); // fire-and-forget; safe if called frequently

        // update markers (preserve warteg marker)
        refreshMarkers();

        // center map
        // _centerMapToCurrentPosition(position);

        // heavier ops
        getAddressFromCoordinates(position.latitude, position.longitude);
        updateLocationToSupabase(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint('❌ Error starting location tracking: $e');
    }
  }

  // -----------------------
  // Location settings
  // -----------------------
  LocationSettings _getLocationSettings() {
    LocationAccuracy accuracy = locationMode.value == 'gps'
        ? LocationAccuracy.best
        : LocationAccuracy.low;
    currentAccuracyText.value = locationMode.value == 'gps'
        ? 'GPS (Akurasi Terbaik)'
        : 'Network (Hemat Baterai)';

    return LocationSettings(
      accuracy: accuracy,
      distanceFilter: 10,
    );
  }

  Future<void> switchLocationMode(String mode) async {
    if (locationMode.value == mode) return;
    print('🔄 Switching location mode to: $mode');
    locationMode.value = mode;

    // restart stream
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    startLocationTracking();

    // refresh last pos
    await getCurrentLocation();

    Get.snackbar('Mode Lokasi', 'Berubah ke ${currentAccuracyText.value}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2));
  }

  // -----------------------
  // Set target warteg (hardcoded)
  // -----------------------
  void setHardcodedWarteg() {
    setTargetLocation(
        LatLng(-7.919807, 112.597628)); // ganti koordinat sesuai warteg
  }

  void setTargetLocation(LatLng latLng) {
    targetLocation.value = latLng;
    refreshMarkers();
    if (currentPosition.value != null) {
      _computeDistanceToTarget(currentPosition.value!);
      fetchRouteFromOSRM();
    }
  }

  // -----------------------
  // Markers (user circular blue, warteg red icon)
  // -----------------------
  void refreshMarkers() {
    final List<Marker> newMarkers = [];

    // user marker (circle blue)
    if (currentPosition.value != null) {
      newMarkers.add(
        Marker(
          point: LatLng(currentPosition.value!.latitude,
              currentPosition.value!.longitude),
          width: 48,
          height: 48,
          // some older flutter_map Marker implementations use 'child' instead of 'builder'
          child: Container(
            alignment: Alignment.center,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
            ),
          ),
        ),
      );
    }

    // warteg marker (icon red)
    if (targetLocation.value != null) {
      newMarkers.add(
        Marker(
          point: targetLocation.value!,
          width: 64,
          height: 64,
          child: const Icon(Icons.location_on, color: Colors.red, size: 36),
        ),
      );
    }

    markers.value = newMarkers;
  }

  // -----------------------
  // Distance calculation
  // -----------------------
  void _computeDistanceToTarget(Position userPos) {
    if (targetLocation.value == null) return;

    final now = DateTime.now();
    if (_lastDistanceCalcAt != null &&
        now.difference(_lastDistanceCalcAt!).inMilliseconds <
            _distanceMinIntervalMillis) {
      return;
    }
    _lastDistanceCalcAt = now;

    final Distance dist = Distance();
    final meters = dist.as(
      LengthUnit.Meter,
      LatLng(userPos.latitude, userPos.longitude),
      targetLocation.value!,
    );

    distanceToTargetMeters.value = meters;

    if (meters <= 50 && !_arrivalNotified) {
      _arrivalNotified = true;
      _showArrivalNotification();
    }
  }

  String formattedDistance() {
    final m = distanceToTargetMeters.value;
    if (m <= 0) return '-';
    if (m < 1000) return '${m.toStringAsFixed(0)} m';
    return '${(m / 1000).toStringAsFixed(2)} km';
  }

  // -----------------------
  // Fetch route from OSRM (follow roads)
  // -----------------------
  Future<void> fetchRouteFromOSRM() async {
    final start = currentPosition.value;
    final dest = targetLocation.value;
    if (start == null || dest == null) return;

    try {
      final url = Uri.parse(
        "http://router.project-osrm.org/route/v1/driving/"
        "${start.longitude},${start.latitude};${dest.longitude},${dest.latitude}"
        "?overview=full&geometries=geojson",
      );

      final resp = await http.get(url);
      if (resp.statusCode != 200) {
        // don't spam logs - print once
        print("OSRM ERROR: ${resp.statusCode}");
        return;
      }

      final data = json.decode(resp.body);
      final coords =
          data['routes']?[0]?['geometry']?['coordinates'] as List<dynamic>?;

      if (coords == null || coords.isEmpty) {
        print('OSRM: no coords');
        return;
      }

      final List<LatLng> routePoints = coords.map<LatLng>((c) {
        final coord = c as List<dynamic>;
        final lon = coord[0] as num;
        final lat = coord[1] as num;
        return LatLng(lat.toDouble(), lon.toDouble());
      }).toList();

      polylines.value = [
        Polyline(points: routePoints, strokeWidth: 4.0, color: Colors.green),
      ];
    } catch (e) {
      print('Route fetch error: $e');
    }
  }

  void _showArrivalNotification() {
    final notificationService = Get.find<NotificationService>();

    notificationService.flutterLocalNotificationsPlugin.show(
      1,
      '📍 Anda Sudah Sampai',
      'Anda sudah berada di dekat Warteg Almera',
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          'Arrival Notification',
          channelDescription: 'Notifikasi saat user tiba di lokasi warteg',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // -----------------------
  // Center map
  // -----------------------
  void _centerMapToCurrentPosition(Position position) {
    try {
      mapController.move(LatLng(position.latitude, position.longitude), 15.0);
    } catch (e) {
      debugPrint('⚠️ Map controller not ready yet: $e');
    }
  }

  // -----------------------
  // Get current location (single)
  // -----------------------
  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled)
        throw Exception('Layanan lokasi tidak aktif. Aktifkan GPS Anda.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied)
          throw Exception('Izin lokasi ditolak.');
      }
      if (permission == LocationPermission.deniedForever)
        throw Exception('Izin lokasi ditolak permanen.');

      final settings = _getLocationSettings();
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: settings.accuracy);

      currentPosition.value = pos;
      currentLatLng.value = LatLng(pos.latitude, pos.longitude);

      _computeDistanceToTarget(pos);
      fetchRouteFromOSRM();
      refreshMarkers();

      _centerMapToCurrentPosition(pos);
      await getAddressFromCoordinates(pos.latitude, pos.longitude);
      await updateLocationToSupabase(pos.latitude, pos.longitude);

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception:', '');
      Get.snackbar('Error Lokasi', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // -----------------------
  // Geocoding
  // -----------------------
  Future<void> getAddressFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final p = placemarks[0];
        currentAddress.value =
            '${p.street ?? ''}, ${p.subLocality ?? ''}, ${p.locality ?? ''}';
      }
    } catch (e) {
      currentAddress.value = 'Alamat tidak ditemukan';
    }
  }

  // -----------------------
  // Supabase update
  // -----------------------
  Future<void> updateLocationToSupabase(double lat, double lon) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;
      await supabase.from('profiles').upsert({
        'id': userId,
        'latitude': lat,
        'longitude': lon,
        'updated_at': DateTime.now().toIso8601String(),
      });
      debugPrint("supabse masuk");
    } catch (e) {
      print('Supabase update error: $e');
    }
  }

  // -----------------------
  // Open settings
  // -----------------------
  void openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}