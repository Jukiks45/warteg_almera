import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/location_controller.dart';

class LocationView extends GetView<LocationController> {
  const LocationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Saya'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () async {
              // dapatkan posisi dulu
              await controller.getCurrentLocation();

              // jika target sebelumnya dihapus, restore hardcoded warteg otomatis
              if (controller.targetLocation.value == null) {
                controller.setHardcodedWarteg();
              }
            },
            tooltip: 'Pusatkan ke lokasi saya',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Mendapatkan lokasi Anda...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        if (controller.hasError.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 80, color: Colors.red[300]),
                  const SizedBox(height: 24),
                  Text('Gagal Mendapatkan Lokasi',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                      onPressed: () => controller.getCurrentLocation(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi')),
                  const SizedBox(height: 12),
                  TextButton.icon(
                      onPressed: () => controller.openLocationSettings(),
                      icon: const Icon(Icons.settings),
                      label: const Text('Buka Pengaturan')),
                ],
              ),
            ),
          );
        }

        if (controller.currentPosition.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_searching,
                    size: 80, color: Colors.blue[300]),
                const SizedBox(height: 24),
                Text('Menunggu lokasi...',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text('Pastikan GPS Anda aktif',
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return Stack(
          children: [
            FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter:
                    controller.currentLatLng.value ?? LatLng(-6.2088, 106.8456),
                initialZoom: 15.0,
                minZoom: 5.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.warteg_almera',
                  tileProvider: NetworkTileProvider(),
                ),

                // Polyline
                Obx(() {
                  return controller.polylines.isNotEmpty
                      ? PolylineLayer(polylines: controller.polylines)
                      : const SizedBox.shrink();
                }),

                // Markers
                MarkerLayer(markers: controller.markers),
              ],
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -5))
                    ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2))),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoSection(context,
                                icon: Icons.location_on,
                                title: 'Koordinat',
                                children: [
                                  _buildInfoRow(
                                      'Latitude',
                                      controller.currentPosition.value!.latitude
                                          .toStringAsFixed(6)),
                                  _buildInfoRow(
                                      'Longitude',
                                      controller
                                          .currentPosition.value!.longitude
                                          .toStringAsFixed(6)),
                                  _buildInfoRow('Akurasi',
                                      '${controller.currentPosition.value!.accuracy.toStringAsFixed(1)} m'),
                                  _buildInfoRow('Kecepatan',
                                      '${controller.currentPosition.value!.speed.toStringAsFixed(1)} m/s'),
                                  _buildInfoRow(
                                      'Waktu Data',
                                      controller
                                          .currentPosition.value!.timestamp
                                          .toLocal()
                                          .toString()
                                          .substring(11, 19)),
                                  _buildInfoRow('Mode',
                                      controller.currentAccuracyText.value),
                                ]),
                            const SizedBox(height: 16),
                            _buildInfoSection(context,
                                icon: Icons.home,
                                title: 'Alamat',
                                children: [
                                  Text(
                                      controller.currentAddress.value.isNotEmpty
                                          ? controller.currentAddress.value
                                          : 'Mencari alamat...',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                          height: 1.5)),
                                ]),
                            const SizedBox(height: 16),
                            _buildInfoSection(
                              context,
                              icon: Icons.store,
                              title: 'Warteg Almeera',
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Jarak di kiri
                                    Text(
                                      'Jarak: ${controller.formattedDistance()}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),

                                    // Tombol kecil di kanan
                                    TextButton(
                                      onPressed: () {
                                        controller.polylines.value = [];
                                        controller.refreshMarkers();
                                      },
                                      child: const Text(
                                        'Sembunyikan Rute',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 4),
                                        minimumSize: Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const SizedBox.shrink(),
                          ]),
                    ),
                  ],
                ),
              ),
            ),

            // Top-right controls
            Positioned(
              top: 16,
              right: 16,
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 2))
                      ]),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text('Tracking Aktif',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 2))
                      ]),
                  child: Row(children: [
                    _buildModeButton(
                        'GPS', Icons.gps_fixed, 'gps', Colors.blue),
                    _buildModeButton(
                        'Network', Icons.cell_tower, 'network', Colors.orange),
                  ]),
                ),
                const SizedBox(height: 8),
                Obx(() => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2))
                        ]),
                    child: Text(controller.currentAccuracyText.value,
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500)))),
              ]),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoSection(BuildContext context,
      {required IconData icon,
      required String title,
      required List<Widget> children}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 20, color: Colors.blue[600]),
        const SizedBox(width: 8),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold))
      ]),
      const SizedBox(height: 8),
      ...children,
    ]);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))
        ]));
  }

  Widget _buildModeButton(
      String label, IconData icon, String mode, Color color) {
    return Obx(() {
      final isSelected = controller.locationMode.value == mode;
      return GestureDetector(
        onTap: () => controller.switchLocationMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
              color: isSelected ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(15)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon,
                size: 14, color: isSelected ? Colors.white : Colors.grey[600]),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.grey[700]))
          ]),
        ),
      );
    });
  }
}
