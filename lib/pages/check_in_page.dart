import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/attendance_service.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

enum _CheckInStatus { preparing, camera, preview, submitting, success, failed }

class _CheckInPageState extends State<CheckInPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  XFile? _selfie;
  Position? _position;
  _CheckInStatus _status = _CheckInStatus.preparing;
  String? _errorMessage;

  bool get _isCameraReady =>
      _cameraController != null && _cameraController!.value.isInitialized;

  String get _locationLabel {
    final position = _position;
    if (position == null) {
      return 'Location unavailable';
    }

    return '${position.latitude.toStringAsFixed(6)}, '
        '${position.longitude.toStringAsFixed(6)}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startFlow());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed &&
        _status == _CheckInStatus.camera) {
      _initializeCamera();
    }
  }

  Future<void> _startFlow() async {
    await _requestAccess();
    if (!mounted || _status == _CheckInStatus.failed) {
      return;
    }

    final confirmed = await _showBackgroundAppsSheet();
    if (!mounted) {
      return;
    }

    if (!confirmed) {
      Navigator.pop(context, false);
      return;
    }

    await _initializeCamera();
  }

  Future<void> _requestAccess() async {
    setState(() {
      _status = _CheckInStatus.preparing;
      _errorMessage = null;
    });

    final cameraPermission = await Permission.camera.request();
    if (!cameraPermission.isGranted) {
      _fail('Camera access is required to take your attendance selfie.');
      return;
    }

    final locationPermission = await Permission.locationWhenInUse.request();
    if (!locationPermission.isGranted) {
      _fail('Location access is required to verify your attendance.');
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _fail('Please turn on location services and try again.');
      return;
    }

    try {
      _position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (_position?.isMocked == true) {
        _fail('Mock location detected. Please turn it off and try again.');
      }
    } catch (_) {
      _fail('We could not read your current location. Please try again.');
    }
  }

  Future<bool> _showBackgroundAppsSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _IconBadge(
                      icon: Icons.verified_user_outlined,
                      backgroundColor: const Color(0xFFEAF2FF),
                      foregroundColor: const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Security check',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Before taking your selfie, close all background apps from recent apps to reduce fake GPS risk.',
                  style: TextStyle(
                    height: 1.45,
                    fontSize: 15,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('I have closed them'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      await _cameraController?.dispose();
      final controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _status = _CheckInStatus.camera;
        _errorMessage = null;
      });
    } catch (_) {
      _fail('Camera is not available. Please check permission and try again.');
    }
  }

  Future<void> _takeSelfie() async {
    if (!_isCameraReady) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      if (!mounted) {
        return;
      }

      setState(() {
        _selfie = image;
        _status = _CheckInStatus.preview;
      });
    } catch (_) {
      _fail('We could not capture your selfie. Please try again.');
    }
  }

  Future<void> _retake() async {
    setState(() {
      _selfie = null;
      _status = _CheckInStatus.camera;
      _errorMessage = null;
    });
    if (!_isCameraReady) {
      await _initializeCamera();
    }
  }

  Future<void> _submitAttendance() async {
    final selfie = _selfie;
    if (selfie == null) {
      _fail('Please take a selfie before continuing.');
      return;
    }

    setState(() {
      _status = _CheckInStatus.submitting;
      _errorMessage = null;
    });

    try {
      final imageUrl = await AttendanceService.uploadImage(selfie.path);
      print('Uploaded Image URL: $imageUrl');
      await AttendanceService.createAttendance(
        status: 'HADIR',
        location: _locationLabel,
        notes: 'Check-in selfie verified',
        imageUrl: imageUrl,
      );

      if (!mounted) {
        return;
      }

      setState(() => _status = _CheckInStatus.success);
    } catch (error) {
      _fail(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _fail(String message) {
    if (!mounted) {
      return;
    }

    setState(() {
      _status = _CheckInStatus.failed;
      _errorMessage = message;
    });
  }

  void _goHome({required bool success}) {
    Navigator.pop(context, success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F8FC),
        foregroundColor: const Color(0xFF111827),
        title: const Text(
          'Check In',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: switch (_status) {
            _CheckInStatus.preparing => _PreparingView(
              key: const ValueKey('preparing'),
              title: 'Preparing secure check-in',
              subtitle: 'Checking camera and location access.',
            ),
            _CheckInStatus.camera => _CameraView(
              key: const ValueKey('camera'),
              controller: _cameraController,
              location: _locationLabel,
              onTakeSelfie: _takeSelfie,
            ),
            _CheckInStatus.preview => _PreviewView(
              key: const ValueKey('preview'),
              selfie: _selfie!,
              location: _locationLabel,
              onRetake: _retake,
              onContinue: _submitAttendance,
            ),
            _CheckInStatus.submitting => _PreparingView(
              key: const ValueKey('submitting'),
              title: 'Submitting attendance',
              subtitle: 'Uploading your selfie and check-in details.',
            ),
            _CheckInStatus.success => _ResultView(
              key: const ValueKey('success'),
              isSuccess: true,
              title: 'Successfully Present',
              message: 'Your check-in has been recorded.',
              primaryLabel: 'Home',
              onPrimary: () => _goHome(success: true),
            ),
            _CheckInStatus.failed => _ResultView(
              key: const ValueKey('failed'),
              isSuccess: false,
              title: 'Check In Failed',
              message: _errorMessage ?? 'Something went wrong.',
              primaryLabel: 'Try Again',
              onPrimary: _startFlow,
              secondaryLabel: 'Home',
              onSecondary: () => _goHome(success: false),
            ),
          },
        ),
      ),
    );
  }
}

class _PreparingView extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PreparingView({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF2FF),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraView extends StatelessWidget {
  final CameraController? controller;
  final String location;
  final VoidCallback onTakeSelfie;

  const _CameraView({
    super.key,
    required this.controller,
    required this.location,
    required this.onTakeSelfie,
  });

  @override
  Widget build(BuildContext context) {
    final cameraController = controller;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          _StepHeader(
            label: 'Selfie verification',
            title: 'Align your face inside the frame',
            subtitle: 'Use the front camera in a well-lit area.',
            icon: Icons.face_retouching_natural_outlined,
          ),
          const SizedBox(height: 18),
          Expanded(child: _CameraFrame(controller: cameraController)),
          const SizedBox(height: 16),
          _InfoPill(icon: Icons.location_on_outlined, label: location),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: cameraController?.value.isInitialized == true
                  ? onTakeSelfie
                  : null,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Take Selfie'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraFrame extends StatelessWidget {
  final CameraController? controller;

  const _CameraFrame({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cameraController = controller;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (cameraController != null &&
                cameraController.value.isInitialized)
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: CameraPreview(cameraController),
              )
            else
              const Center(child: CircularProgressIndicator()),
            const _FaceGuide(),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.48),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.light_mode_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Keep your face clear and centered',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaceGuide extends StatelessWidget {
  const _FaceGuide();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 210,
        height: 280,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: BorderRadius.circular(120),
        ),
      ),
    );
  }
}

class _PreviewView extends StatelessWidget {
  final XFile selfie;
  final String location;
  final VoidCallback onRetake;
  final VoidCallback onContinue;

  const _PreviewView({
    super.key,
    required this.selfie,
    required this.location,
    required this.onRetake,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          _StepHeader(
            label: 'Result',
            title: 'Review your selfie',
            subtitle: 'Continue when your face is visible and clear.',
            icon: Icons.fact_check_outlined,
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(selfie.path), fit: BoxFit.cover),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: _PreviewMeta(location: location),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRetake,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retake'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onContinue,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continue'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewMeta extends StatelessWidget {
  final String location;

  const _PreviewMeta({required this.location});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _MetaRow(icon: Icons.schedule, label: time),
          const SizedBox(height: 6),
          _MetaRow(icon: Icons.location_on_outlined, label: location),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final bool isSuccess;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const _ResultView({
    super.key,
    required this.isSuccess,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final backgroundColor = isSuccess
        ? const Color(0xFFEAFBF0)
        : const Color(0xFFFFF1F2);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check_rounded : Icons.close_rounded,
              color: color,
              size: 118,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 30,
              height: 1.12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              height: 1.45,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPrimary,
              style: FilledButton.styleFrom(
                backgroundColor: isSuccess ? const Color(0xFF16A34A) : color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(primaryLabel),
            ),
          ),
          if (secondaryLabel != null && onSecondary != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onSecondary,
                child: Text(secondaryLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String label;
  final String title;
  final String subtitle;
  final IconData icon;

  const _StepHeader({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _IconBadge(
            icon: icon,
            backgroundColor: const Color(0xFFEAF2FF),
            foregroundColor: const Color(0xFF2563EB),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const _IconBadge({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: foregroundColor, size: 25),
    );
  }
}
