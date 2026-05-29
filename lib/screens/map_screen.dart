import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/route_model.dart';
import '../models/route_point.dart';
import '../providers/tracking_provider.dart';
import '../services/route_service.dart';
import '../services/statistics_service.dart';
import '../services/step_service.dart';
import '../services/user_service.dart';
import '../utils/distance_formatter.dart';
import '../utils/permission_helper.dart';
import '../widgets/route_data.dart';
import 'result_screen.dart';

const _background = Color(0xFF101415);
const _cardColor = Color(0xE6101415);
const _panelColor = Color(0xE61C2B31);
const _lineColor = Color(0x283BEA72);
const _lime = Color(0xFFB6FF00);
const _textMuted = Color(0xFFD0D6C9);
const _stopColor = Color(0xFFFFA8A1);

const double defaultZoom = 18;

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
  Completer<GoogleMapController>();
  final StepService _stepService = StepService();

  LatLng? _currentPos;
  StreamSubscription<LocationData>? _uiLocationSubscription;

  bool _followUser = true;
  bool _isProgrammaticMove = false;
  bool _isSavingRoute = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _checkLocationPermissions();
    _initializeMapRenderer();
  }

  void _initializeMapRenderer() {
    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;

    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
    }
  }

  @override
  void dispose() {
    _uiLocationSubscription?.cancel();
    _stepService.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _checkLocationPermissions() async {
    bool serviceEnabled = await _locationController.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();

      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionGranted =
    await _locationController.hasPermission();

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();

      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final locationData = await _locationController.getLocation();

    if (mounted &&
        locationData.latitude != null &&
        locationData.longitude != null) {
      setState(() {
        _currentPos = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
      });
    }

    _uiLocationSubscription = _locationController.onLocationChanged.listen(
          (location) {
        if (location.latitude == null || location.longitude == null) {
          return;
        }

        if (!mounted) {
          return;
        }

        final newPos = LatLng(
          location.latitude!,
          location.longitude!,
        );

        setState(() {
          _currentPos = newPos;
        });

        if (_followUser) {
          _updateCameraPosition(newPos);
        }
      },
    );
  }

  Future<void> _updateCameraPosition(LatLng position) async {
    final GoogleMapController controller = await _mapController.future;

    _isProgrammaticMove = true;
    controller.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  Future<void> _startRoute(TrackingProvider trackingProvider) async {
    if (_isSavingRoute) {
      return;
    }

    final hasBgPerm =
    await PermissionHelper.requestBackgroundLocationPermission(context);

    if (!hasBgPerm) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Taustal asukoha õigus on jälgimise alustamiseks vajalik.',
          ),
        ),
      );
      return;
    }

    _stepService.startCounting();
    await trackingProvider.startTracking();
  }

  Future<void> _stopRoute(TrackingProvider trackingProvider) async {
    if (_isSavingRoute) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kasutaja pole sisse logitud'),
        ),
      );
      return;
    }

    setState(() {
      _isSavingRoute = true;
    });

    try {
      final endTime = DateTime.now();
      final trackedDuration = trackingProvider.duration;

      await trackingProvider.stopTracking();

      final steps = await _stepService.stopCounting();

      final distanceKm = trackingProvider.totalDistance / 1000;
      final durationSeconds = trackedDuration.inSeconds;

      final startTime = endTime.subtract(
        Duration(seconds: durationSeconds),
      );

      final averageSpeed = durationSeconds <= 0
          ? 0.0
          : distanceKm / (durationSeconds / 3600);

      final profile = await UserService().getUserProfile(user.uid);
      final profileWeight = profile?.weightKg ?? 70.0;
      final weightKg = profileWeight <= 0 ? 70.0 : profileWeight;

      final calories = weightKg * distanceKm * 0.9;

      final routeId = 'route_${DateTime.now().millisecondsSinceEpoch}';

      final route = RouteModel(
        routeId: routeId,
        userId: user.uid,
        title: 'Uus marsruut',
        startTime: startTime,
        endTime: endTime,
        distanceKm: distanceKm,
        durationSeconds: durationSeconds,
        steps: steps,
        calories: calories,
        averageSpeed: averageSpeed,
        activityType: 'walking',
        createdAt: endTime,
      );

      final savedPoints = List<LatLng>.from(trackingProvider.routePoints);

      final pointInterval = savedPoints.length <= 1
          ? 0.0
          : durationSeconds / (savedPoints.length - 1);

      final routePoints = savedPoints.asMap().entries.map((entry) {
        final index = entry.key;
        final point = entry.value;

        return RoutePoint(
          pointId: 'point_$index',
          routeId: routeId,
          latitude: point.latitude,
          longitude: point.longitude,
          accuracy: 0,
          altitude: 0,
          timestamp: startTime.add(
            Duration(seconds: (pointInterval * index).round()),
          ),
        );
      }).toList();

      await RouteService().saveRoute(
        route: route,
        points: routePoints,
      );

      await StatisticsService().calculateAndSaveDailySummary(
        userId: user.uid,
        date: endTime,
      );

      if (!mounted) return;

      final routeSummary = RouteSummary(
        title: route.title,
        date: route.startTime,
        startTime: TimeOfDay.fromDateTime(route.startTime),
        endTime: TimeOfDay.fromDateTime(route.endTime),
        distanceKm: route.distanceKm,
        duration: Duration(seconds: route.durationSeconds),
        steps: route.steps,
        calories: route.calories.round(),
        averageSpeed: route.averageSpeed,
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(route: routeSummary),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marsruudi salvestamine ebaõnnestus: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingRoute = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackingProvider = Provider.of<TrackingProvider>(context);

    return DecoratedBox(
      decoration: const BoxDecoration(color: _background),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              top: 90,
              child: _currentPos == null
                  ? const Center(
                child: CircularProgressIndicator(color: _lime),
              )
                  : GoogleMap(
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: trackingProvider.routePoints,
                    color: _lime,
                    width: 5,
                  ),
                },
                onMapCreated: (controller) {
                  if (!_mapController.isCompleted) {
                    _mapController.complete(controller);
                  }
                },
                initialCameraPosition: CameraPosition(
                  target: _currentPos!,
                  zoom: defaultZoom,
                ),
                onCameraMoveStarted: () {
                  if (!_isProgrammaticMove && _followUser) {
                    setState(() {
                      _followUser = false;
                    });
                  }

                  _isProgrammaticMove = false;
                },
              ),
            ),
            Positioned.fill(
              top: 90,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _background.withValues(alpha: 0.16),
                        Colors.transparent,
                        _background.withValues(alpha: 0.20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                const _MapHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _TopStats(
                          distanceKm: trackingProvider.totalDistance / 1000,
                          duration: trackingProvider.duration,
                        ),
                        const SizedBox(height: 16),
                        _MapToolButton(
                          icon: _followUser
                              ? Icons.my_location
                              : Icons.location_searching,
                          active: _followUser,
                          onPressed: () {
                            setState(() {
                              _followUser = true;
                            });

                            if (_currentPos != null) {
                              _updateCameraPosition(_currentPos!);
                            }
                          },
                        ),
                        const Spacer(),
                        _RouteControlPanel(
                          tracking: trackingProvider.isTracking,
                          saving: _isSavingRoute,
                          onPause: () async {
                            if (trackingProvider.isTracking) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Marsruudi salvestamiseks vajuta Stop.',
                                  ),
                                ),
                              );
                              return;
                            }

                            await _startRoute(trackingProvider);
                          },
                          onStop: trackingProvider.isTracking && !_isSavingRoute
                              ? () {
                            _stopRoute(trackingProvider);
                          }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isSavingRoute)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.42),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: _lime),
                        SizedBox(height: 16),
                        Text(
                          'Salvestan marsruuti...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: _background,
        border: Border(
          bottom: BorderSide(color: Color(0x1FFFFFFF)),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 48),
          const Expanded(
            child: Text(
              'RouteFit',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
            color: Colors.white,
            iconSize: 30,
            tooltip: 'Seaded',
          ),
        ],
      ),
    );
  }
}

class _TopStats extends StatelessWidget {
  const _TopStats({
    required this.distanceKm,
    required this.duration,
  });

  final double distanceKm;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatGlassCard(
            label: 'Tempo',
            value: _formatPace(distanceKm, duration),
            suffix: '/km',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatGlassCard(
            label: 'Vahemaa',
            value: formatDistanceValue(distanceKm),
            suffix: formatDistanceUnit(distanceKm),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatGlassCard(
            label: 'Aeg',
            value: formatDuration(duration),
          ),
        ),
      ],
    );
  }
}

class _StatGlassCard extends StatelessWidget {
  const _StatGlassCard({
    required this.label,
    required this.value,
    this.suffix = '',
  });

  final String label;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _lineColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99030607),
            blurRadius: 26,
            offset: Offset(0, 16),
          ),
          BoxShadow(
            color: Color(0x2235F46E),
            blurRadius: 26,
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xE3293E47),
            Color(0xE61A2A31),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.visible,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: _lime,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  if (suffix.isNotEmpty)
                    TextSpan(
                      text: ' $suffix',
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteControlPanel extends StatelessWidget {
  const _RouteControlPanel({
    required this.tracking,
    required this.saving,
    required this.onPause,
    required this.onStop,
  });

  final bool tracking;
  final bool saving;
  final VoidCallback onPause;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _lineColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0xB0000000),
            blurRadius: 34,
            offset: Offset(0, 18),
          ),
          BoxShadow(
            color: Color(0x3335F46E),
            blurRadius: 30,
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(child: _GpsIndicator()),
          _RoundRouteButton(
            icon: tracking ? Icons.pause : Icons.play_arrow,
            foreground: _lime,
            background: Colors.transparent,
            borderColor: _lime,
            onPressed: saving ? null : onPause,
            tooltip: tracking ? 'Paus' : 'Alusta',
          ),
          const SizedBox(width: 14),
          _RoundRouteButton(
            icon: Icons.stop,
            foreground: const Color(0xFF6B1212),
            background: _stopColor,
            borderColor: _stopColor,
            onPressed: saving ? null : onStop,
            tooltip: 'Peata',
          ),
        ],
      ),
    );
  }
}

class _GpsIndicator extends StatelessWidget {
  const _GpsIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: _lime,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x8835F46E),
                blurRadius: 16,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GPS jälgimine',
                maxLines: 1,
                style: TextStyle(
                  color: _lime,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Kõrge täpsus',
                maxLines: 1,
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundRouteButton extends StatelessWidget {
  const _RoundRouteButton({
    required this.icon,
    required this.foreground,
    required this.background,
    required this.borderColor,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final Color foreground;
  final Color background;
  final Color borderColor;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: onPressed == null ? 0.55 : 1,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.22),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: foreground,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}

class _MapToolButton extends StatelessWidget {
  const _MapToolButton({
    required this.icon,
    this.active = false,
    this.onPressed,
  });

  final IconData icon;
  final bool active;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: active ? _lime.withValues(alpha: 0.2) : _cardColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? _lime : _lineColor,
          ),
          boxShadow: [
            if (active)
              const BoxShadow(
                color: Color(0x3335F46E),
                blurRadius: 12,
              ),
          ],
        ),
        child: Icon(
          icon,
          color: active ? _lime : _textMuted,
          size: 28,
        ),
      ),
    );
  }
}

String _formatPace(double distanceKm, Duration duration) {
  if (distanceKm <= 0 || duration == Duration.zero) {
    return "0'00";
  }

  final totalSeconds = duration.inSeconds / distanceKm;
  final minutes = totalSeconds ~/ 60;
  final seconds = (totalSeconds % 60).round().toString().padLeft(2, '0');

  return "$minutes'$seconds";
}