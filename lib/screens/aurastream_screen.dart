import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import '../services/aethera_theme.dart';

class RealityPatch {
  final String id;
  final String title;
  final String description;
  final String creator;
  final String injectPath;
  final String fileName;
  final String fileContent;
  final Color themeColor;
  final String patchType; // 'vortex', 'bubbles', 'waves', 'matrix'
  int likes;
  int shares;
  int downloads;
  bool isInjected;
  bool isLiked;

  RealityPatch({
    required this.id,
    required this.title,
    required this.description,
    required this.creator,
    required this.injectPath,
    required this.fileName,
    required this.fileContent,
    required this.themeColor,
    required this.patchType,
    this.likes = 1200,
    this.shares = 450,
    this.downloads = 320,
    this.isInjected = false,
    this.isLiked = false,
  });
}

class AuraStreamScreen extends StatefulWidget {
  const AuraStreamScreen({super.key});

  @override
  State<AuraStreamScreen> createState() => _AuraStreamScreenState();
}

class _AuraStreamScreenState extends State<AuraStreamScreen> {
  final List<RealityPatch> _patches = [
    RealityPatch(
      id: 'timeline_14b',
      title: 'Timeline Shift 14B',
      description: 'Injects quantum fluctuations to align your device events with a high-probability luck timeline (Timeline 14-B). Attracts coincidental positive outcomes.',
      creator: 'QuantumArchitect',
      injectPath: 'quantum_timeline.json',
      fileName: 'timeline_14b.json',
      fileContent: jsonEncode({
        "matrix": "Timeline-14B",
        "calibration": "98.7%",
        "luck_coefficient": 3.42,
        "coincidence_alignment": "optimal",
        "signature": "SHA256-Q14B-ALIGN"
      }),
      themeColor: AetheraTheme.neonPurple,
      patchType: 'vortex',
      likes: 9823,
      shares: 3102,
      downloads: 4210,
    ),
    RealityPatch(
      id: 'gravity_decel',
      title: 'Anti-Gravity Decelerator',
      description: 'Simulates local minor gravity distortion around device sensors. Writes spatial calibrations to stabilize device gyroscope coordinates.',
      creator: 'AeroTesla_101',
      injectPath: 'gyro_gravity.conf',
      fileName: 'gravity_decel.conf',
      fileContent: jsonEncode({
        "gravity_bias": -0.0512,
        "sensor_damping": 0.88,
        "axis_alignment": "X-Y-Z-Quantum",
        "stabilizer_loop": "active"
      }),
      themeColor: AetheraTheme.neonCyan,
      patchType: 'bubbles',
      likes: 4211,
      shares: 980,
      downloads: 1420,
    ),
    RealityPatch(
      id: 'neural_sync',
      title: 'Brain-Wave Neural Sync',
      description: 'Generates alpha & theta binaural feedback nodes through mobile speaker drivers. Injects acoustic configurations for peak creative focus.',
      creator: 'HoloSound_Labs',
      injectPath: 'audio_resonance.xml',
      fileName: 'neural_sync.xml',
      fileContent: '''<?xml version="1.0" encoding="utf-8"?>
<acoustic_patch id="neural_sync">
  <mode>CreativeFocus</mode>
  <frequencies alpha="8.5Hz" theta="4.0Hz" />
  <driver_alignment>true</driver_alignment>
</acoustic_patch>''',
      themeColor: AetheraTheme.neonMagenta,
      patchType: 'waves',
      likes: 7654,
      shares: 2410,
      downloads: 3870,
    ),
    RealityPatch(
      id: 'luck_matrix',
      title: 'Entropy Probability Patch',
      description: 'Modifies device runtime math constants to skew random operations towards positive entropy structures. Improves lottery/game probability curves.',
      creator: 'EntropyBreaker',
      injectPath: 'luck_constants.dat',
      fileName: 'luck_matrix.dat',
      fileContent: 'ENTROPY_CONSTANT=0.981723;RANDOM_BIAS=LUCK_POSITIVE;CALIB=TRUE',
      themeColor: AetheraTheme.neonGreen,
      patchType: 'matrix',
      likes: 12450,
      shares: 5120,
      downloads: 8790,
    ),
  ];

  bool _injecting = false;
  double _injectProgress = 0.0;
  String _injectStatus = '';

  Future<void> _injectPatch(RealityPatch patch) async {
    if (_injecting) return;
    setState(() {
      _injecting = true;
      _injectProgress = 0.0;
      _injectStatus = 'Tách hạt lượng tử...';
    });

    // Simulated high-tech scan steps
    final steps = [
      'Giải mã cấu trúc Reality Matrix...',
      'Thiết lập cổng lượng tử thiết bị...',
      'Đang tiêm gói tin vào Documents/${patch.fileName}...',
      'Đồng bộ hóa tần số thực tại...'
    ];

    for (int i = 0; i < steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() {
        _injectProgress = (i + 1) / steps.length;
        _injectStatus = steps[i];
      });
    }

    try {
      // Physically write the file to the local sandbox
      final appDir = await getApplicationDocumentsDirectory();
      final targetFile = File('${appDir.path}/${patch.fileName}');
      await targetFile.writeAsString(patch.fileContent);

      setState(() {
        patch.isInjected = true;
        patch.downloads += 1;
      });

      _showSuccessDialog(patch);
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _injecting = false;
        });
      }
    }
  }

  void _showSuccessDialog(RealityPatch patch) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AetheraTheme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: patch.themeColor.withOpacity(0.5), width: 1.5),
        ),
        title: Text(
          'TIÊM THỰC TẠI THÀNH CÔNG',
          style: AetheraTheme.neonTextStyle(fontSize: 16, color: patch.themeColor, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: AetheraTheme.neonGreen, size: 60)
                .animate()
                .scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text(
              'Giao thức "${patch.title}" đã được cài đặt vào hệ thống.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Path: App Documents/${patch.fileName}',
                style: const TextStyle(color: Colors.white30, fontSize: 10, fontFamily: 'Menlo'),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('ĐỒNG BỘ THỜI GIAN', style: TextStyle(color: patch.themeColor, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  void _showErrorDialog(String err) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AetheraTheme.cardBg,
        title: const Text('LỖI LIÊN KẾT LƯỢNG TỬ', style: TextStyle(color: Colors.red)),
        content: Text(err),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AetheraTheme.spaceBg,
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: _patches.length,
            itemBuilder: (ctx, i) {
              final patch = _patches[i];
              return _buildFeedItem(patch);
            },
          ),
          if (_injecting) _buildInjectOverlay(),
        ],
      ),
    );
  }

  Widget _buildFeedItem(RealityPatch patch) {
    return Stack(
      children: [
        // Background Particle Generator (Mysterious Visual)
        Positioned.fill(
          child: _QuantumVisualBackdrop(patchType: patch.patchType, color: patch.themeColor),
        ),

        // Dark Overlay for readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Title and Info
        Positioned(
          left: 16,
          right: 80,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: patch.themeColor, width: 1.5),
                      boxShadow: [
                        BoxShadow(color: patch.themeColor.withOpacity(0.3), blurRadius: 8)
                      ],
                    ),
                    child: Center(
                      child: Text(
                        patch.creator[0],
                        style: TextStyle(color: patch.themeColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '@${patch.creator}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                patch.title,
                style: AetheraTheme.neonTextStyle(fontSize: 22, color: patch.themeColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                patch.description,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _injectPatch(patch),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [patch.themeColor, patch.themeColor.withOpacity(0.6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: patch.themeColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          patch.isInjected ? 'TIÊM LẠI THỰC TẠI' : 'TIÊM THỰC TẠI (QUANTUM INJECT)',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
        ),

        // Social Buttons on the right
        Positioned(
          right: 16,
          bottom: 24,
          child: Column(
            children: [
              _SocialAction(
                icon: Icons.favorite_rounded,
                label: '${patch.likes + (patch.isLiked ? 1 : 0)}',
                color: patch.isLiked ? Colors.red : Colors.white,
                onTap: () {
                  setState(() {
                    patch.isLiked = !patch.isLiked;
                  });
                },
              ),
              const SizedBox(height: 20),
              _SocialAction(
                icon: Icons.download_rounded,
                label: '${patch.downloads}',
                color: patch.isInjected ? AetheraTheme.neonGreen : Colors.white,
                onTap: () => _injectPatch(patch),
              ),
              const SizedBox(height: 20),
              _SocialAction(
                icon: Icons.share_rounded,
                label: '${patch.shares}',
                color: Colors.white,
                onTap: () {
                  setState(() {
                    patch.shares += 1;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã liên kết mạng lưới chia sẻ lượng tử!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInjectOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rotating neon core
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _injectProgress,
                      strokeWidth: 4,
                      color: AetheraTheme.neonPurple,
                      backgroundColor: Colors.white10,
                    ),
                    const Icon(Icons.flash_on_rounded, color: AetheraTheme.neonCyan, size: 48)
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 1200.ms),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'TIÊM LIÊN KẾT THỜI GIAN',
                style: AetheraTheme.neonTextStyle(fontSize: 16, color: AetheraTheme.neonPurple, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _injectStatus,
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                '${(_injectProgress * 100).toInt()}%',
                style: const TextStyle(color: Colors.white38, fontSize: 12, fontFamily: 'Menlo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ─── BACKGROUND PHYSICS ANIMATORS ──────────────────────────────────────────

class _QuantumVisualBackdrop extends StatefulWidget {
  final String patchType;
  final Color color;

  const _QuantumVisualBackdrop({required this.patchType, required this.color});

  @override
  State<_QuantumVisualBackdrop> createState() => _QuantumVisualBackdropState();
}

class _QuantumVisualBackdropState extends State<_QuantumVisualBackdrop>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, child) {
        return CustomPaint(
          painter: _QuantumPainter(
            time: _ctrl.value,
            patchType: widget.patchType,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _QuantumPainter extends CustomPainter {
  final double time;
  final String patchType;
  final Color color;

  _QuantumPainter({required this.time, required this.patchType, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    if (patchType == 'vortex') {
      // Temporal Vortex Spiral
      final points = <Offset>[];
      final spiralTurns = 12;
      final maxRadius = size.width * 0.8;
      
      for (double theta = 0; theta < spiralTurns * 2 * math.pi; theta += 0.05) {
        final progress = theta / (spiralTurns * 2 * math.pi);
        final r = progress * maxRadius;
        final angle = theta + time * 4 * math.pi;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        points.add(Offset(x, y));
      }

      for (int i = 0; i < points.length - 1; i++) {
        final factor = i / points.length;
        paint.color = color.withOpacity(0.7 * (1 - factor));
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    } else if (patchType == 'bubbles') {
      // Floating Gravity Bubbles
      final rand = math.Random(42);
      paint.style = PaintingStyle.fill;
      for (int i = 0; i < 25; i++) {
        final scaleX = rand.nextDouble() * size.width;
        final baseSpeed = 1.0 + rand.nextDouble() * 2.0;
        final yProgress = (time * baseSpeed + rand.nextDouble()) % 1.0;
        final scaleY = size.height * (1.0 - yProgress);
        final radius = 3.0 + rand.nextDouble() * 8.0;
        
        paint.color = color.withOpacity(0.3 * (1.0 - yProgress));
        canvas.drawCircle(Offset(scaleX, scaleY), radius, paint);
      }
    } else if (patchType == 'waves') {
      // Neural Sine Waves
      paint.strokeWidth = 1.5;
      final waveCount = 5;
      for (int w = 0; w < waveCount; w++) {
        final points = <Offset>[];
        final waveOffset = w * 40.0;
        final speed = (1 + w * 0.5) * time * 2 * math.pi;

        for (double x = 0; x < size.width; x += 5) {
          final angle = (x / size.width) * 4 * math.pi + speed;
          final y = center.dy - 60 + waveOffset + math.sin(angle) * 30;
          points.add(Offset(x, y));
        }

        for (int i = 0; i < points.length - 1; i++) {
          paint.color = color.withOpacity(0.4 * (1 - w / waveCount));
          canvas.drawLine(points[i], points[i + 1], paint);
        }
      }
    } else if (patchType == 'matrix') {
      // Downward Falling Cascade Columns
      paint.style = PaintingStyle.fill;
      final columnCount = 18;
      final rand = math.Random(123);

      for (int c = 0; c < columnCount; c++) {
        final colWidth = size.width / columnCount;
        final x = c * colWidth + colWidth / 2;
        final baseSpeed = 0.5 + rand.nextDouble() * 1.5;
        final streamLength = 8 + rand.nextInt(12);

        for (int s = 0; s < streamLength; s++) {
          final progress = (time * baseSpeed + s / streamLength) % 1.0;
          final y = progress * size.height;
          final opacity = (1.0 - s / streamLength) * 0.35;
          final sizeDot = 2.0 + (1.0 - s / streamLength) * 4.0;
          
          paint.color = color.withOpacity(opacity);
          canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: sizeDot, height: sizeDot), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
