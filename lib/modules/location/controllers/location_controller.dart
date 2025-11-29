import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

class LocationController extends GetxController {
  var isLoading = false.obs;
  var currentPosition = Rxn<Position>();
  var currentAddress = ''.obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;
  
  // Flutter Map controller
  final mapController = MapController();
  
  // Supabase client
  final supabase = Supabase.instance.client;
  
  // Position stream subscription
  StreamSubscription<Position>? _positionStreamSubscription;
  
  // Observables for map
  var currentLatLng = Rxn<LatLng>();
  var markers = <Marker>[].obs;
  
  // Location mode: 'gps', 'network'
  var locationMode = 'gps'.obs;
  var currentAccuracyText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    currentAccuracyText.value = 'GPS (Akurasi Terbaik)'; // Default mode
    getCurrentLocation();
    startLocationTracking();
  }

  @override
  void onClose() {
    _positionStreamSubscription?.cancel();
    super.onClose();
  }

  /// Start real-time location tracking
  void startLocationTracking() async {
    try {
      // Check permissions first
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Location service not enabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('⚠️ Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('⚠️ Location permission denied forever');
        return;
      }

      print('🎯 Starting location tracking with mode: ${locationMode.value}');

      // Location settings based on selected mode
      final LocationSettings locationSettings = _getLocationSettings();

      // Listen to position stream
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) async {
          print('📍 Location updated: ${position.latitude}, ${position.longitude}');
          
          currentPosition.value = position;
          currentLatLng.value = LatLng(position.latitude, position.longitude);
          
          // Update marker on map
          _updateMarker(position);
          
          // Auto-center map to current position
          _centerMapToCurrentPosition(position);
          
          // Update address
          await getAddressFromCoordinates(position.latitude, position.longitude);
          
          // Update location to Supabase
          await updateLocationToSupabase(position.latitude, position.longitude);
        },
        onError: (error) {
          print('❌ Location stream error: $error');
        },
      );
    } catch (e) {
      print('❌ Error starting location tracking: $e');
    }
  }

  /// Get location settings based on selected mode
  LocationSettings _getLocationSettings() {
    LocationAccuracy accuracy;
    
    switch (locationMode.value) {
      case 'gps':
        accuracy = LocationAccuracy.best; // GPS only - highest accuracy
        currentAccuracyText.value = 'GPS (Akurasi Terbaik)';
        break;
      case 'network':
      default:
        accuracy = LocationAccuracy.low; // Network only - battery efficient
        currentAccuracyText.value = 'Network (Hemat Baterai)';
        break;
    }
    
    return LocationSettings(
      accuracy: accuracy,
      distanceFilter: 10, // Update every 10 meters
    );
  }
  
  /// Switch location mode and restart tracking
  Future<void> switchLocationMode(String mode) async {
    if (locationMode.value == mode) return;
    
    print('🔄 Switching location mode to: $mode');
    locationMode.value = mode;
    
    // Restart tracking with new mode
    await _positionStreamSubscription?.cancel();
    startLocationTracking();
    
    // Also refresh current position
    await getCurrentLocation();
    
    Get.snackbar(
      'Mode Lokasi',
      'Berubah ke ${currentAccuracyText.value}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Update marker on map
  void _updateMarker(Position position) {
    markers.value = [
      Marker(
        point: LatLng(position.latitude, position.longitude),
        width: 80,
        height: 80,
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40,
        ),
      ),
    ];
  }

  /// Auto-center map to current position
  void _centerMapToCurrentPosition(Position position) {
    try {
      mapController.move(
        LatLng(position.latitude, position.longitude),
        15.0, // Zoom level
      );
    } catch (e) {
      print('⚠️ Map controller not ready yet: $e');
    }
  }

  /// Update location to Supabase profiles table
  Future<void> updateLocationToSupabase(double latitude, double longitude) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      
      if (userId == null) {
        print('⚠️ User not logged in, skipping Supabase update');
        return;
      }

      print('💾 Updating location to Supabase...');
      
      await supabase.from('profiles').upsert({
        'id': userId,
        'latitude': latitude,
        'longitude': longitude,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      print('✅ Location updated to Supabase');
    } catch (e) {
      print('❌ Error updating location to Supabase: $e');
      // Don't show error to user, just log it
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      print('🗺️ Checking location permissions...');

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi tidak aktif. Aktifkan GPS Anda.');
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print('⚠️ Location permission denied, requesting...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Izin lokasi ditolak permanen. Aktifkan di pengaturan aplikasi.',
        );
      }

      print('✅ Location permission granted');
      print('📍 Getting current position with mode: ${locationMode.value}...');

      // Get current position based on selected mode
      final settings = _getLocationSettings();
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: settings.accuracy,
      );

      currentPosition.value = position;
      currentLatLng.value = LatLng(position.latitude, position.longitude);
      
      // Update marker and center map
      _updateMarker(position);
      _centerMapToCurrentPosition(position);
      
      print('✅ Position obtained: ${position.latitude}, ${position.longitude}');

      // Get address from coordinates
      await getAddressFromCoordinates(position.latitude, position.longitude);
      
      // Update to Supabase
      await updateLocationToSupabase(position.latitude, position.longitude);

      isLoading.value = false;
    } catch (e) {
      print('❌ Error getting location: $e');
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      
      Get.snackbar(
        'Error Lokasi',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> getAddressFromCoordinates(double lat, double lon) async {
    try {
      print('🏠 Getting address from coordinates...');
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        currentAddress.value = 
          '${place.street ?? ''}, ${place.subLocality ?? ''}, '
          '${place.locality ?? ''}, ${place.subAdministrativeArea ?? ''}, '
          '${place.administrativeArea ?? ''} ${place.postalCode ?? ''}';
        
        print('✅ Address obtained: ${currentAddress.value}');
      } else {
        currentAddress.value = 'Alamat tidak ditemukan';
      }
    } catch (e) {
      print('❌ Error getting address: $e');
      currentAddress.value = 'Gagal mendapatkan alamat';
    }
  }

  Future<void> openMaps() async {
    if (currentPosition.value != null) {
      final lat = currentPosition.value!.latitude;
      final lon = currentPosition.value!.longitude;
      
      // You can add url_launcher here to open Google Maps
      Get.snackbar(
        'Lokasi',
        'Lat: $lat, Lon: $lon',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        'Lokasi belum tersedia',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
