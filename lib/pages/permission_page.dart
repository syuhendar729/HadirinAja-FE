import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/app_config.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

enum _PermissionStatus {
  preparing,
  camera,
  preview,
  submitting,
  success,
  failed,
}

class _PermissionPageState extends State<PermissionPage>
    with WidgetsBindingObserver {
  static const String _developmentLocationName = 'Institut Teknologi Sumatera';
  static const double _developmentLatitude = -5.3600000;
  static const double _developmentLongitude = 105.3150000;

  final TextEditingController _notesController = TextEditingController();
  CameraController? _cameraController;
  XFile? _proofImage;
  Position? _position;
  _PermissionStatus _status = _PermissionStatus.preparing;
  String? _errorMessage;

  bool get _isCameraReady =>
      _cameraController != null && _cameraController!.value.isInitialized;

  double? get _latitude {
    if (AppConfig.isDevelopment) {
      return _developmentLatitude;
    }

    return _position?.latitude;
  }

  double? get _longitude {
    if (AppConfig.isDevelopment) {
      return _developmentLongitude;
    }

    return _position?.longitude;
  }

  String get _attendanceLocation {
    if (AppConfig.isDevelopment) {
      return _developmentLocationName;
    }

    return _locationLabel;
  }

  String get _locationLabel {
    if (AppConfig.isDevelopment) {
      return '${_developmentLatitude.toStringAsFixed(6)}, '
          '${_developmentLongitude.toStringAsFixed(6)}';
    }

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
    _notesController.dispose();
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
        _status == _PermissionStatus.camera) {
      _initializeCamera();
    }
  }

  Future<void> _startFlow() async {
    await _requestAccess();
    if (!mounted || _status == _PermissionStatus.failed) {
      return;
    }

    await _initializeCamera();
  }

  Future<void> _requestAccess() async {
    setState(() {
      _status = _PermissionStatus.preparing;
      _errorMessage = null;
    });

    final cameraPermission = await Permission.camera.request();
    if (!cameraPermission.isGranted) {
      _fail('Camera access is required to capture leave proof.');
      return;
    }

    if (AppConfig.isDevelopment) {
      return;
    }

    final locationPermission = await Permission.locationWhenInUse.request();
    if (!locationPermission.isGranted) {
      _fail('Location access is required to submit leave.');
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

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      await _cameraController?.dispose();
      final controller = CameraController(
        backCamera,
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
        _status = _PermissionStatus.camera;
        _errorMessage = null;
      });
    } catch (_) {
      _fail('Camera is not available. Please check permission and try again.');
    }
  }

  Future<void> _takeProofImage() async {
    if (!_isCameraReady) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      if (!mounted) {
        return;
      }

      setState(() {
        _proofImage = image;
        _status = _PermissionStatus.preview;
      });
    } catch (_) {
      _fail('We could not capture your leave proof. Please try again.');
    }
  }

  Future<void> _retake() async {
    setState(() {
      _proofImage = null;
      _status = _PermissionStatus.camera;
      _errorMessage = null;
    });
    if (!_isCameraReady) {
      await _initializeCamera();
    }
  }

  Future<void> _submitPermission() async {
    final proofImage = _proofImage;
    final latitude = _latitude;
    final longitude = _longitude;
    final notes = _notesController.text.trim();

    if (proofImage == null) {
      _fail('Please capture your leave proof before submitting.');
      return;
    }

    if (notes.isEmpty) {
      _fail('Please add notes for your leave request.');
      return;
    }

    if (latitude == null || longitude == null) {
      _fail('Location is unavailable. Please try again.');
      return;
    }

    setState(() {
      _status = _PermissionStatus.submitting;
      _errorMessage = null;
    });

    try {
      final imageUrl = await AttendanceService.uploadImage(proofImage.path);
      await AttendanceService.createAttendance(
        status: AttendanceStatus.absent.apiValue,
        location: _attendanceLocation,
        notes: notes,
        imageUrl: imageUrl,
        latitude: latitude,
        longitude: longitude,
      );

      if (!mounted) {
        return;
      }

      setState(() => _status = _PermissionStatus.success);
    } catch (error) {
      _fail(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _fail(String message) {
    if (!mounted) {
      return;
    }

    setState(() {
      _status = _PermissionStatus.failed;
      _errorMessage = message;
    });
  }

  void _goHome({required bool success}) {
    Navigator.pop(context, success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(AppColors.background),
        foregroundColor: const Color(AppColors.textPrimary),
        title: const Text(
          'Leave',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: switch (_status) {
            _PermissionStatus.preparing => const _PreparingView(
              key: ValueKey('preparing'),
              title: 'Preparing leave request',
              subtitle: 'Checking camera and location access.',
            ),
            _PermissionStatus.camera => _CameraView(
              key: const ValueKey('camera'),
              controller: _cameraController,
              location: _locationLabel,
              notesController: _notesController,
              onTakeProof: _takeProofImage,
            ),
            _PermissionStatus.preview => _PreviewView(
              key: const ValueKey('preview'),
              proofImage: _proofImage!,
              location: _locationLabel,
              notesController: _notesController,
              onRetake: _retake,
              onSubmit: _submitPermission,
            ),
            _PermissionStatus.submitting => const _PreparingView(
              key: ValueKey('submitting'),
              title: 'Submitting leave',
              subtitle: 'Uploading your proof and leave details.',
            ),
            _PermissionStatus.success => _ResultView(
              key: const ValueKey('success'),
              title: 'Waiting for approval',
              message: 'Your leave request has been submitted.',
              primaryLabel: 'Home',
              onPrimary: () => _goHome(success: true),
            ),
            _PermissionStatus.failed => _ResultView(
              key: const ValueKey('failed'),
              title: 'Leave Request Failed',
              message: _errorMessage ?? 'Something went wrong.',
              primaryLabel: 'Try Again',
              onPrimary: _startFlow,
              secondaryLabel: 'Home',
              onSecondary: () => _goHome(success: false),
              isError: true,
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
                color: Color(0xFFFFF7ED),
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
                color: Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(AppColors.textSecondary),
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
  final TextEditingController notesController;
  final VoidCallback onTakeProof;

  const _CameraView({
    super.key,
    required this.controller,
    required this.location,
    required this.notesController,
    required this.onTakeProof,
  });

  @override
  Widget build(BuildContext context) {
    final cameraController = controller;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          _StepHeader(
            label: 'Leave proof',
            title: 'Capture your proof document',
            subtitle: 'Take a clear photo of your letter or document.',
            icon: Icons.description_outlined,
          ),
          const SizedBox(height: 18),
          Expanded(child: _CameraFrame(controller: cameraController)),
          const SizedBox(height: 14),
          _NotesField(controller: notesController),
          const SizedBox(height: 12),
          _InfoPill(icon: Icons.location_on_outlined, label: location),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: cameraController?.value.isInitialized == true
                  ? onTakeProof
                  : null,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Take Proof'),
              style: FilledButton.styleFrom(
                backgroundColor: AttendanceStatus.leave.accentColor,
                foregroundColor: AttendanceStatus.leave.foregroundColor,
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
          color: const Color(AppColors.textPrimary),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (cameraController != null &&
                cameraController.value.isInitialized)
              CameraPreview(cameraController)
            else
              const Center(child: CircularProgressIndicator()),
            const _DocumentGuide(),
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
                        'Keep the proof document readable',
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

class _DocumentGuide extends StatelessWidget {
  const _DocumentGuide();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 250,
        height: 330,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

class _PreviewView extends StatelessWidget {
  final XFile proofImage;
  final String location;
  final TextEditingController notesController;
  final VoidCallback onRetake;
  final VoidCallback onSubmit;

  const _PreviewView({
    super.key,
    required this.proofImage,
    required this.location,
    required this.notesController,
    required this.onRetake,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          _StepHeader(
            label: 'Review',
            title: 'Check your leave proof',
            subtitle: 'Submit when the document and notes are complete.',
            icon: Icons.fact_check_outlined,
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(proofImage.path), fit: BoxFit.cover),
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
          const SizedBox(height: 14),
          _NotesField(controller: notesController),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRetake,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retake'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(AppColors.textPrimary),
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
                  onPressed: onSubmit,
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Submit'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AttendanceStatus.leave.accentColor,
                    foregroundColor: AttendanceStatus.leave.foregroundColor,
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

class _NotesField extends StatelessWidget {
  final TextEditingController controller;

  const _NotesField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 2,
      maxLines: 3,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: 'Notes',
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.edit_note_outlined),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(AppColors.border)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AttendanceStatus.leave.accentColor,
            width: 1.4,
          ),
        ),
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
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool isError;

  const _ResultView({
    super.key,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? AttendanceStatus.absent.accentColor
        : AttendanceStatus.leave.accentColor;
    final backgroundColor = isError
        ? const Color(0xFFFFF1F2)
        : const Color(0xFFFFF7ED);

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
              isError ? Icons.close_rounded : Icons.priority_high_rounded,
              color: color,
              size: 118,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(AppColors.textPrimary),
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
              color: Color(AppColors.textSecondary),
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
                backgroundColor: color,
                foregroundColor: isError
                    ? Colors.white
                    : AttendanceStatus.leave.foregroundColor,
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
            backgroundColor: const Color(0xFFFFF7ED),
            foregroundColor: const Color(AppColors.warning),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: Color(AppColors.warning),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(AppColors.textPrimary),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(AppColors.textSecondary),
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
        border: Border.all(color: const Color(AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(AppColors.warning), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(AppColors.textPrimary),
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
