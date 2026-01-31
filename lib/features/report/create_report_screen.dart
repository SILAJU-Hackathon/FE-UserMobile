import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:silaju/core/constants/app_colors.dart';
import 'package:silaju/core/constants/app_strings.dart';
import 'package:silaju/core/constants/app_sizes.dart';
import 'package:silaju/features/report/providers/report_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Create report screen with step-by-step flow
class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  File? _imageFile;
  final _picker = ImagePicker();

  // Map state
  final MapController _mapController = MapController();
  LatLng _selectedLocation =
      const LatLng(-7.2575, 112.7521); // Surabaya default
  bool _isLoadingLocation = false;
  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  bool _isSnapping = false;
  LatLng? _userInitialLocation; // Cached user location for speed
  bool _isMovingProgrammatically = false; // Flag to prevent event loops
  AnimationController? _mapAnimationController;
  bool _skipNextSnap = false; // Prevent snapping after search selection

  // Form controllers
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _searchController = TextEditingController();
  String _addressDetail = '';
  bool _isConfirmed = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _searchController.dispose();
    _mapController.dispose();
    _mapAnimationController?.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom,
      {Duration duration = const Duration(milliseconds: 1000)}) {
    // Stop any current animation and reset flag to be safe
    _mapAnimationController?.stop();
    _mapAnimationController?.dispose();
    _isMovingProgrammatically = false;

    _isMovingProgrammatically = true;
    final latTween = Tween<double>(
        begin: _mapController.camera.center.latitude,
        end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _mapController.camera.center.longitude,
        end: destLocation.longitude);
    final zoomTween =
        Tween<double>(begin: _mapController.camera.zoom, end: destZoom);

    _mapAnimationController =
        AnimationController(duration: duration, vsync: this);
    final Animation<double> animation = CurvedAnimation(
        parent: _mapAnimationController!, curve: Curves.fastOutSlowIn);

    _mapAnimationController!.addListener(() {
      _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isMovingProgrammatically = false;
        // Small delay to ensure any remaining move events are processed/ignored
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) _onMapMoveEnd(_mapController.camera);
        });
      } else if (status == AnimationStatus.dismissed ||
          status == AnimationStatus.completed) {
        _isMovingProgrammatically = false;
      }
    });

    _mapAnimationController!.forward();
  }

  /// Snap coordinates to the nearest road using OSRM API
  Future<LatLng> _snapToRoad(LatLng location) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/nearest/v1/driving/${location.longitude},${location.latitude}',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'SILAJU-App/1.0',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok' && data['waypoints'].isNotEmpty) {
          final snappedLon = data['waypoints'][0]['location'][0];
          final snappedLat = data['waypoints'][0]['location'][1];
          return LatLng(snappedLat, snappedLon);
        }
      }
    } catch (e) {
      print('Snap to road error: $e');
    }
    return location; // Return original if fails
  }

  /// Search location using Nominatim API
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5&addressdetails=1&countrycodes=id',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'SILAJU-App/1.0',
      });

      if (response.statusCode == 200) {
        setState(() {
          _searchResults = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Search error: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _onSearchResultSelected(dynamic result) {
    final lat = double.parse(result['lat']);
    final lon = double.parse(result['lon']);
    final location = LatLng(lat, lon);

    setState(() {
      _selectedLocation = location;
      _searchResults = [];
      _searchController.clear();

      final address = result['address'] as Map<String, dynamic>?;
      if (address != null) {
        _locationController.text = address['road'] ??
            address['suburb'] ??
            address['village'] ??
            'Lokasi tanpa nama';

        final List<String> details = [];
        if (address['suburb'] != null &&
            address['suburb'] != _locationController.text) {
          details.add(address['suburb']);
        }
        if (address['city'] != null) details.add(address['city']);
        if (address['state'] != null) details.add(address['state']);
        _addressDetail = details.join(', ');
      } else {
        _locationController.text = 'Lokasi terpilih';
        _addressDetail = result['display_name'] ?? '';
      }
    });

    _skipNextSnap = true; // Don't snap immediately after search
    FocusScope.of(context).unfocus();
    _animatedMapMove(location, 17);
  }

  /// Get current GPS location
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationController.text = 'GPS tidak aktif. Silakan aktifkan.';
        return;
      }

      // 2. Check/Request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _locationController.text = 'Izin lokasi ditolak';
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _locationController.text =
            'Izin lokasi ditolak permanen. Cek pengaturan.';
        return;
      }

      // 3. Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final location = LatLng(position.latitude, position.longitude);

      // Store initial location for fast return
      _userInitialLocation = location;

      // Snap to road for initial location too
      final snappedLocation = await _snapToRoad(location);

      setState(() {
        _selectedLocation = snappedLocation;
      });

      // 4. Move map with safety delay
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        _animatedMapMove(_selectedLocation, 17);
      }

      // 5. Reverse geocode
      await _reverseGeocode(_selectedLocation);
    } catch (e) {
      print('Error getting location: $e');
      _locationController.text = 'Gagal mengambil GPS';
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  /// Reverse geocode to get street name from coordinates
  Future<void> _reverseGeocode(LatLng location) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&zoom=18&addressdetails=1',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'SILAJU-App/1.0',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          setState(() {
            _locationController.text = address['road'] ??
                address['suburb'] ??
                address['village'] ??
                'Lokasi tanpa nama';

            final List<String> details = [];
            if (address['suburb'] != null &&
                address['suburb'] != _locationController.text) {
              details.add(address['suburb']);
            }
            if (address['city'] != null) details.add(address['city']);
            if (address['state'] != null) details.add(address['state']);
            _addressDetail = details.join(', ');
          });
        } else {
          setState(() {
            _locationController.text = 'Lokasi tidak diketahui';
            _addressDetail = data['display_name'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Reverse geocode error: $e');
    }
  }

  /// When user stops dragging the map
  void _onMapMoveEnd(MapCamera camera) async {
    // Only block if we are in the middle of a programmatic animation
    if (_isMovingProgrammatically) return;

    final currentCenter = camera.center;

    // Snapping to nearest road ONLY if zoomed in enough
    if (camera.zoom >= 15.5 && !_skipNextSnap && !_isSnapping) {
      final snappedLocation = await _snapToRoad(currentCenter);

      // Check if distance is significant enough to snap
      final latDiff = (snappedLocation.latitude - currentCenter.latitude).abs();
      final lonDiff =
          (snappedLocation.longitude - currentCenter.longitude).abs();

      if (latDiff > 0.000001 || lonDiff > 0.000001) {
        _isSnapping = true;

        // Update state locally first
        setState(() {
          _selectedLocation = snappedLocation;
        });

        // Use a faster animation for snapping
        if (mounted) {
          _animatedMapMove(snappedLocation, camera.zoom,
              duration: const Duration(milliseconds: 300));
        }

        // Delay to allow animation to settle
        await Future.delayed(const Duration(milliseconds: 400));
        _isSnapping = false;
        return;
      }
    }

    _skipNextSnap = false; // Reset flag

    setState(() {
      _selectedLocation = currentCenter;
    });

    await _reverseGeocode(_selectedLocation);
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submitReport();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitReport() async {
    if (_imageFile == null || !_isConfirmed) return;

    await ref.read(reportProvider.notifier).submitReport(
          imageFile: _imageFile!,
          lat: _selectedLocation.latitude,
          lng: _selectedLocation.longitude,
          description: _descriptionController.text,
          roadName: _locationController.text,
        );

    // Listen to state changes is handled in build
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 50, // Compress image
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportProvider);

    // Handle success/error listeners
    ref.listen(reportProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil dikirim! +50 XP'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentStep > 0 ? _previousStep : () => context.pop(),
        ),
        title: const Text(AppStrings.createReport),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.md),
            child: Center(
              child: Text(
                '${_currentStep + 1}/3',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: (_currentStep + 1) / 3,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
                minHeight: 4,
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: _buildStepContent(),
                ),
              ),

              // Bottom button
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // XP hint
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.xpGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt, color: AppColors.xpGold, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            AppStrings.xpHint,
                            style: TextStyle(
                              color: AppColors.xpGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_currentStep == 0 && _imageFile == null) ||
                                (_currentStep == 2 && !_isConfirmed) ||
                                reportState.isLoading
                            ? null
                            : _nextStep,
                        child: reportState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text(
                                _currentStep == 2
                                    ? AppStrings.submitReport
                                    : '${AppStrings.next} →',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Loading overlay (optional double protection)
          if (reportState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPhotoStep();
      case 1:
        return _buildLocationStep();
      case 2:
        return _buildDetailsStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPhotoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.takePhoto,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          AppStrings.photoSubtitle,
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.lg),

        // Photo placeholder
        GestureDetector(
          onTap: () => _pickImage(ImageSource.camera),
          child: Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.mintGreen.withOpacity(0.3),
                  AppColors.mintGreen.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: AppColors.mintGreen,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg - 2),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: AppSizes.md,
                          right: AppSizes.md,
                          child: ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text(AppStrings.changePhoto),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.mintGreen.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          size: 32,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      const Text(
                        AppStrings.tapToTakePhoto,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          AppStrings.required,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: AppSizes.md),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text(AppStrings.camera),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text(AppStrings.gallery),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),

        // Tips card
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.photoTipsTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.photoTips,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.selectLocation,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.lg),

        // Search bar
        TextField(
          controller: _searchController,
          onChanged: (val) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(const Duration(milliseconds: 500), () {
              _searchLocation(val);
            });
          },
          onSubmitted: (val) {
            FocusScope.of(context).unfocus();
            _searchLocation(val);
          },
          decoration: InputDecoration(
            hintText: AppStrings.searchAddress,
            prefixIcon: const Icon(Icons.search),
            fillColor: AppColors.white,
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchLocation('');
                        },
                      )
                    : null,
          ),
        ),

        // Search Results list
        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              separatorBuilder: (ctx, idx) => Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final result = _searchResults[idx];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(
                    result['display_name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  onTap: () => _onSearchResultSelected(result),
                );
              },
            ),
          ),

        const SizedBox(height: AppSizes.md),

        // FlutterMap with OpenStreetMap
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedLocation,
                  initialZoom: 17,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                  onMapEvent: (event) {
                    if (event is MapEventMoveEnd &&
                        !_isMovingProgrammatically) {
                      _onMapMoveEnd(_mapController.camera);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}@2x?access_token=${dotenv.env['MAPBOX_ACCESS_TOKEN']}',
                    userAgentPackageName: 'com.silaju.app',
                    maxZoom: 19,
                  ),
                ],
              ),

              // Center pin (fixed overlay)
              // We translate it up by 24px (half of size 48) so the tip points exactly at the map center
              Center(
                child: Transform.translate(
                  offset: const Offset(0, -24),
                  child: const Icon(
                    Icons.location_on,
                    size: 48,
                    color: AppColors.error,
                  ),
                ),
              ),

              // Loading indicator
              if (_isLoadingLocation)
                const Center(
                  child: CircularProgressIndicator(),
                ),

              // Current location button
              Positioned(
                right: AppSizes.md,
                bottom: AppSizes.md,
                child: FloatingActionButton.small(
                  onPressed: () {
                    if (_userInitialLocation != null) {
                      _animatedMapMove(_userInitialLocation!, 17);
                    } else {
                      _getCurrentLocation();
                    }
                  },
                  backgroundColor: AppColors.white,
                  child: const Icon(Icons.my_location,
                      color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),

        // Location card
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.location_on, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _locationController.text.isNotEmpty
                          ? _locationController.text
                          : 'Mencari lokasi...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _addressDetail.isNotEmpty ? _addressDetail : '...',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Konfirmasi Laporan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.lg),

        // Description
        const Text(
          'Catatan Opsional',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSizes.sm),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Tambahkan detail atau patokan lokasi jika perlu...',
            fillColor: AppColors.white,
          ),
        ),
        const SizedBox(height: AppSizes.xl),

        // Confirmation Checkbox
        Container(
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            color: _isConfirmed
                ? AppColors.primaryBlue.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: _isConfirmed
                  ? AppColors.primaryBlue.withOpacity(0.2)
                  : AppColors.border,
            ),
          ),
          child: InkWell(
            onTap: () => setState(() => _isConfirmed = !_isConfirmed),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.xs, vertical: AppSizes.xs),
              child: Row(
                children: [
                  Checkbox(
                    value: _isConfirmed,
                    onChanged: (val) =>
                        setState(() => _isConfirmed = val ?? false),
                    activeColor: AppColors.primaryBlue,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Saya mengonfirmasi bahwa data yang diinput valid dan akan tercatat dalam sistem.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
