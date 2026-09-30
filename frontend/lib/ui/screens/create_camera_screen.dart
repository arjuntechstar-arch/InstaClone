import 'package:flutter/material.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

class CreateCameraScreen extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onCapture;
  final VoidCallback onClose;

  const CreateCameraScreen({
    super.key,
    required this.onCapture,
    required this.onClose,
  });

  @override
  State<CreateCameraScreen> createState() => _CreateCameraScreenState();
}

class _CreateCameraScreenState extends State<CreateCameraScreen> {
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  bool _isGridOn = true;
  int _selectedFilterIndex = 0;

  final List<String> _filters = [
    'NORMAL',
    'NEON GLITCH',
    'CYAN MATRIX',
    'UV INFRARED',
    'MONOCHROME',
    'HOLOGRAM',
  ];

  final List<String> _sampleCaptures = [
    'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=800',
    'https://images.unsplash.com/photo-1542051841857-5f90071e7989?w=800',
    'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=800',
  ];

  void _capturePhoto() {
    final chosenMedia = _sampleCaptures[_selectedFilterIndex % _sampleCaptures.length];
    widget.onCapture({
      'mediaUrl': chosenMedia,
      'filterName': _filters[_selectedFilterIndex],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgVoid,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Camera Viewfinder with Cyber Reticle
            Positioned.fill(
              child: CyberReticleWidget(
                cornerLength: 28,
                strokeWidth: 2,
                reticleColor: CyberColors.secondaryCyan,
                child: Container(
                  color: CyberColors.surfaceDark,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Viewfinder simulation stream
                      Image.network(
                        'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=800',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: CyberColors.surfaceElevated,
                          child: const Center(
                            child: Icon(Icons.videocam, color: CyberColors.textMuted, size: 64),
                          ),
                        ),
                      ),

                      // Holographic CRT Scanline Overlay
                      const CyberScanlineOverlay(),

                      // Viewfinder Grid Lines
                      if (_isGridOn)
                        CustomPaint(
                          painter: _GridPainter(color: Colors.white.withValues(alpha: 0.15)),
                        ),

                      // Center HUD Crosshair Reticle
                      Center(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: CyberColors.secondaryCyan.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: CyberColors.secondaryCyan,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Top Controls Bar
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: widget.onClose,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: _isFlashOn ? CyberColors.tertiaryYellow : Colors.white,
                        ),
                        onPressed: () => setState(() => _isFlashOn = !_isFlashOn),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.grid_on,
                          color: _isGridOn ? CyberColors.secondaryCyan : Colors.white54,
                        ),
                        onPressed: () => setState(() => _isGridOn = !_isGridOn),
                      ),
                      IconButton(
                        icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                        onPressed: () => setState(() => _isFrontCamera = !_isFrontCamera),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Filter Carousel & Shutter Button
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Filter Selection Chips
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final isSelected = index == _selectedFilterIndex;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilterIndex = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? CyberColors.primaryHotPink.withValues(alpha: 0.3)
                                  : CyberColors.bgVoid.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? CyberColors.primaryHotPink
                                    : CyberColors.borderSubtle,
                                width: 1.2,
                              ),
                              boxShadow: isSelected
                                  ? CyberColors.pinkGlowShadow(blur: 8)
                                  : null,
                            ),
                            child: Text(
                              _filters[index],
                              style: CyberTypography.hudBadge.copyWith(
                                color: isSelected ? Colors.white : CyberColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Shutter Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _capturePhoto,
                        child: Container(
                          width: 76,
                          height: 76,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: CyberColors.primaryHotPink, width: 3),
                            boxShadow: CyberColors.pinkGlowShadow(blur: 18, spread: 2),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: CyberColors.pinkGlow,
                            ),
                            child: const Center(
                              child: Icon(Icons.camera, color: Colors.white, size: 32),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    final x1 = size.width / 3;
    final x2 = (size.width / 3) * 2;
    final y1 = size.height / 3;
    final y2 = (size.height / 3) * 2;

    canvas.drawLine(Offset(x1, 0), Offset(x1, size.height), paint);
    canvas.drawLine(Offset(x2, 0), Offset(x2, size.height), paint);
    canvas.drawLine(Offset(0, y1), Offset(size.width, y1), paint);
    canvas.drawLine(Offset(0, y2), Offset(size.width, y2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
