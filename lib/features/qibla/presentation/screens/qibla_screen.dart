import 'dart:async';
import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adhan/adhan.dart' as adhan;
import '../../../../core/theme/app_colors.dart';
import 'package:fazakkir/l10n/app_localizations.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Map Variables
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng? _userLocation;
  static const LatLng _kaabaLocation = LatLng(21.422487, 39.826206);
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // Compass Variables
  double? _qiblaBearing;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getUserLocation();
    }
  }

  Future<void> _getUserLocation() async {
    final position = await Geolocator.getCurrentPosition();

    // Calculate Qibla Bearing manually using Adhan package
    final start = adhan.Coordinates(position.latitude, position.longitude);
    final qibla = adhan.Qibla(start);

    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
      _qiblaBearing = qibla.direction; // Direction from North (0-360)
      _initMapLayers();
    });
  }

  void _initMapLayers() {
    if (_userLocation == null) return;

    _markers = {
      Marker(
        markerId: const MarkerId("kaaba"),
        position: _kaabaLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
      Marker(
        markerId: const MarkerId("user"),
        position: _userLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    };

    _polylines = {
      Polyline(
        polylineId: const PolylineId("path"),
        points: [_userLocation!, _kaabaLocation],
        color: AppColors.islamicGold,
        width: 3,
        patterns: [PatternItem.dash(10), PatternItem.gap(5)],
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : const Color(0xfff9f9f9),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.qiblaTitle,
          style: TextStyle(fontFamily: "Bakra", fontSize: 22.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.islamicBrown,
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.islamicGold,
          labelColor: AppColors.islamicGold,
          unselectedLabelColor: Colors.grey,
          labelStyle: TextStyle(
            fontFamily: "Cairo",
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
          tabs: [
            Tab(text: AppLocalizations.of(context)!.compass),
            Tab(text: AppLocalizations.of(context)!.map),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildCompassView(isDark), _buildMapView()],
      ),
    );
  }

  Widget _buildCompassView(bool isDark) {
    if (_userLocation == null || _qiblaBearing == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.compassError("${snapshot.error}"),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.islamicGold),
          );
        }

        final double? heading = snapshot.data?.heading;

        // If heading is null, device might not support compass
        if (heading == null) {
          return Center(
            child: Text(AppLocalizations.of(context)!.deviceNoCompass),
          );
        }

        // 1. Compass Rotation = -heading
        final double compassRotation = -heading * (pi / 180);

        // 2. Needle Rotation = Qibla Bearing (It's fixed on the dial)
        final double needleRotation = _qiblaBearing! * (pi / 180);

        // 3. Alignment Check
        double diff = _qiblaBearing! - heading;
        double diffAbs = diff.abs() % 360;
        if (diffAbs > 180) diffAbs = 360 - diffAbs;
        final bool isAligned = diffAbs < 5;

        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),

              // Fixed Target (The Kaaba) - Top Center
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(isAligned ? 10.sp : 5.sp),
                    decoration: BoxDecoration(
                      color: isAligned
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      boxShadow: isAligned
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF4CAF50,
                                ).withValues(alpha: 0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ]
                          : null,
                    ),
                    child: Image.asset(
                      'assets/images/kaaba.png',
                      width: isAligned ? 70.h : 60.h,
                      height: isAligned ? 70.h : 60.h,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isAligned ? 1.0 : 0.0,
                    child: Text(
                      AppLocalizations.of(context)!.faceQibla,
                      style: TextStyle(
                        color: const Color(0xFF4CAF50),
                        fontFamily: "Cairo",
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Rotating Compass Body (Unified Rotation)
              // Rotate the whole stack by -heading
              // Inside, Needle is rotated by Qibla Bearing
              SizedBox(
                height: 300.h,
                width: 300.h,
                child: Transform.rotate(
                  angle: compassRotation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // A. Compass Dial (North is 0)
                      SvgPicture.asset(
                        'assets/images/compass_ring.svg',
                        height: 300.h,
                        colorFilter: ColorFilter.mode(
                          isDark ? Colors.white70 : const Color(0xff8D6E63),
                          BlendMode.srcIn,
                        ),
                      ),

                      // B. Qibla Needle (Fixed to Qibla Bearing on Dial)
                      Transform.rotate(
                        angle: needleRotation,
                        child: Container(
                          height: 300.h,
                          width: 300.h,
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.only(top: 15.h),
                          child: Icon(
                            Icons.navigation,
                            size: 50.h,
                            color: isAligned
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFD4AF37),
                          ),
                        ),
                      ),

                      // C. Center Pivot
                      Container(
                        width: 10.h,
                        height: 10.h,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.islamicGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // Instructions
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30.w),
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  AppLocalizations.of(context)!.qiblaInstruction,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 14.sp,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              // Debug Info (Small)
              Text(
                "Heading: ${heading.toStringAsFixed(0)}° | Qibla: ${_qiblaBearing!.toStringAsFixed(0)}°",
                style: TextStyle(color: Colors.grey, fontSize: 10.sp),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapView() {
    if (_userLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _userLocation!, zoom: 12),
      markers: _markers,
      polylines: _polylines,
      onMapCreated: (controller) {
        _mapController.complete(controller);
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
