import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import '../viewmodels/location_viewmodel.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final TextEditingController _searchController = TextEditingController();
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  Future<void> _searchAndMove(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final target = LatLng(location.latitude, location.longitude);
        _mapController.move(target, 16);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Endereço não encontrado')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao buscar endereço')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final location = viewModel.location;

        if (location == null) {
          return const Center(
            child: Text('Não foi possível obter a localização.'),
          );
        }

        final currentPos = LatLng(location.latitude, location.longitude);

        // Move o mapa quando a localização for atualizada
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(currentPos, _mapController.camera.zoom);
        });

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar endereço...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed:
                        () => _searchAndMove(_searchController.text.trim()),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: currentPos,
                  initialZoom: 16,
                  keepAlive: true,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'br.edu.ifsul.flutter_mapas_osm',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: currentPos,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
