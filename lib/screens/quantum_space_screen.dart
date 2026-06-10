import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/file_item.dart';
import '../services/file_service.dart';
import '../services/aethera_theme.dart';

class CelestialNode {
  final FileItem item;
  Offset position;
  Offset velocity;
  double radius;
  Color glowColor;
  bool isDragging;
  double angle;
  double orbitRadius;
  double orbitSpeed;

  CelestialNode({
    required this.item,
    required this.position,
    this.velocity = Offset.zero,
    this.radius = 16.0,
    required this.glowColor,
    this.isDragging = false,
    this.angle = 0.0,
    this.orbitRadius = 80.0,
    this.orbitSpeed = 0.02,
  });
}

class QuantumSpaceScreen extends StatefulWidget {
  const QuantumSpaceScreen({super.key});

  @override
  State<QuantumSpaceScreen> createState() => _QuantumSpaceScreenState();
}

class _QuantumSpaceScreenState extends State<QuantumSpaceScreen>
    with SingleTickerProviderStateMixin {
  final FileService _svc = FileService();
  String _currentPath = '';
  List<CelestialNode> _nodes = [];
  bool _loading = true;
  String? _error;
  
  CelestialNode? _draggedNode;
  CelestialNode? _hoveredTargetNode; // Folder being hovered during drag
  late AnimationController _physicsCtrl;
  
  // Navigation stack for back button
  final List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _initPath();
    _physicsCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _physicsCtrl.addListener(_updatePhysics);
  }

  @override
  void dispose() {
    _physicsCtrl.dispose();
    super.dispose();
  }

  Future<void> _initPath() async {
    final path = await _svc.getDefaultPath();
    _loadDirectory(path);
  }

  Future<void> _loadDirectory(String path) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
      _currentPath = path;
    });

    try {
      final items = await _svc.listDirectory(path);
      final size = MediaQuery.of(context).size;
      final center = Offset(size.width / 2, size.height / 2 - 40);
      final rand = math.Random();

      final List<CelestialNode> tempNodes = [];
      
      // Calculate orbits
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final color = item.isDirectory
            ? AetheraTheme.neonPurple
            : _getFileColor(item.extension);

        // Subfolders get larger nodes, files smaller
        final radius = item.isDirectory ? 26.0 : 16.0;
        final orbitR = 70.0 + (i * 24.0);
        final startAngle = rand.nextDouble() * 2 * math.pi;
        final speed = 0.005 + (0.015 * (1.0 / (i + 1)));

        final pos = Offset(
          center.dx + orbitR * math.cos(startAngle),
          center.dy + orbitR * math.sin(startAngle),
        );

        tempNodes.add(
          CelestialNode(
            item: item,
            position: pos,
            radius: radius,
            glowColor: color,
            orbitRadius: orbitR,
            orbitSpeed: speed,
            angle: startAngle,
          ),
        );
      }

      setState(() {
        _nodes = tempNodes;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Color _getFileColor(String ext) {
    switch (ext.toLowerCase()) {
      case 'json':
      case 'conf':
      case 'dat':
        return AetheraTheme.neonCyan;
      case 'txt':
      case 'md':
      case 'xml':
        return AetheraTheme.neonMagenta;
      case 'ipa':
      case 'zip':
        return AetheraTheme.neonGreen;
      default:
        return AetheraTheme.neonMagenta;
    }
  }

  void _updatePhysics() {
    if (_loading || _nodes.isEmpty) return;

    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2 - 40);

    setState(() {
      for (final node in _nodes) {
        if (node.isDragging) continue;

        // Apply orbital rotation around center
        node.angle += node.orbitSpeed;
        final targetX = center.dx + node.orbitRadius * math.cos(node.angle);
        final targetY = center.dy + node.orbitRadius * math.sin(node.angle);

        // Smooth spring pull back to orbit path
        node.position = Offset(
          node.position.dx + (targetX - node.position.dx) * 0.15,
          node.position.dy + (targetY - node.position.dy) * 0.15,
        );
      }
    });
  }

  void _onPanStart(DragStartDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(details.globalPosition);

    for (final node in _nodes) {
      final dist = (node.position - localPos).distance;
      if (dist <= node.radius + 15) {
        setState(() {
          node.isDragging = true;
          _draggedNode = node;
        });
        HapticFeedback.lightImpact();
        break;
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_draggedNode == null) return;
    final renderBox = context.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      _draggedNode!.position = localPos;

      // Check for folder hover (Gravity pull validation)
      _hoveredTargetNode = null;
      if (!_draggedNode!.item.isDirectory) {
        for (final node in _nodes) {
          if (node == _draggedNode || !node.item.isDirectory) continue;
          final dist = (node.position - localPos).distance;
          if (dist < 65.0) {
            _hoveredTargetNode = node;
            break;
          }
        }
      }
    });
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    if (_draggedNode == null) return;
    setState(() {
      _draggedNode!.isDragging = false;
    });

    final target = _hoveredTargetNode;
    final dragged = _draggedNode!;
    
    _draggedNode = null;
    _hoveredTargetNode = null;

    if (target != null && !dragged.item.isDirectory) {
      // Cosmic Merge: Physically move file into folder
      HapticFeedback.mediumImpact();
      final newPath = '${target.item.path}/${dragged.item.name}';
      
      setState(() => _loading = true);
      final success = await _svc.renameItem(dragged.item.path, '${target.item.name}/${dragged.item.name}');
      
      if (success) {
        _showNotification('FUSION: Đã tiêm ${dragged.item.name} -> ${target.item.name}');
      } else {
        _showNotification('LỖI: Trục xuất liên kết lượng tử thất bại', isError: true);
      }
      _loadDirectory(_currentPath);
    }
  }

  void _onNodeTap(CelestialNode node) {
    HapticFeedback.selectionClick();
    _showActionSheet(node);
  }

  void _onNodeDoubleTap(CelestialNode node) {
    if (node.item.isDirectory) {
      HapticFeedback.doubleCheck();
      _history.add(_currentPath);
      _loadDirectory(node.item.path);
    }
  }

  void _navigateUp() {
    if (_history.isNotEmpty) {
      final prev = _history.removeLast();
      _loadDirectory(prev);
    } else {
      final parent = _svc.getParentPath(_currentPath);
      _loadDirectory(parent);
    }
  }

  void _showNotification(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AetheraTheme.neonRed : AetheraTheme.neonPurple,
        content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─── ACTION SHEET ──────────────────────────────────────────
  void _showActionSheet(CelestialNode node) {
    final item = node.item;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xE60D0B1F),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: node.glowColor.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(item.isDirectory ? Icons.blur_circular_rounded : Icons.radio_button_checked_rounded, color: node.glowColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: AetheraTheme.neonTextStyle(fontSize: 16, color: node.glowColor, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        item.isDirectory ? 'Matrix Folder' : 'Reality Constant (${_svc.formatSize(item.sizeBytes)})',
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 24),
            _buildActionItem(
              icon: Icons.vpn_key_rounded,
              label: 'Vòng Đọc Giá Trị (Copy Path)',
              color: Colors.white,
              onTap: () {
                Clipboard.setData(ClipboardData(text: item.path));
                Navigator.pop(context);
                _showNotification('Đã lưu cấu trúc đường dẫn');
              },
            ),
            _buildActionItem(
              icon: Icons.border_color_rounded,
              label: 'Warp Rename (Đổi tên)',
              color: Colors.white,
              onTap: () {
                Navigator.pop(context);
                _renameNode(node);
              },
            ),
            _buildActionItem(
              icon: Icons.delete_sweep_rounded,
              label: 'Tẩy Tế Bào (Cosmic Delete)',
              color: AetheraTheme.neonRed,
              onTap: () {
                Navigator.pop(context);
                _deleteNode(node);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Future<void> _renameNode(CelestialNode node) async {
    String? newName;
    await showDialog(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: node.item.name);
        return AlertDialog(
          backgroundColor: AetheraTheme.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Warp Rename', style: TextStyle(color: node.glowColor, fontSize: 16, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: ctrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: node.glowColor), borderRadius: BorderRadius.circular(10)),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
            TextButton(
              onPressed: () { newName = ctrl.text; Navigator.pop(ctx); },
              child: Text('Apply', style: TextStyle(color: node.glowColor)),
            ),
          ],
        );
      },
    );
    if (newName != null && newName!.isNotEmpty && newName != node.item.name) {
      setState(() => _loading = true);
      final ok = await _svc.renameItem(node.item.path, newName!);
      if (ok) {
        _showNotification('Đổi tên ma trận thành công');
      } else {
        _showNotification('Đổi tên thất bại', isError: true);
      }
      _loadDirectory(_currentPath);
    }
  }

  Future<void> _deleteNode(CelestialNode node) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AetheraTheme.cardBg,
        title: const Text('Phân Rã Vật Chất', style: TextStyle(color: Colors.white)),
        content: Text('Xác nhận phân rã ma trận "${node.item.name}"?', style: const TextStyle(color: Colors.white60)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy', style: TextStyle(color: Colors.white38))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Phân Rã', style: TextStyle(color: AetheraTheme.neonRed))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      final ok = await _svc.deleteItem(node.item.path);
      if (ok) {
        _showNotification('Đã phân rã ma trận khỏi vũ trụ');
      } else {
        _showNotification('Không thể phân rã', isError: true);
      }
      _loadDirectory(_currentPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AetheraTheme.spaceBg,
      body: Stack(
        children: [
          // Background gravity grid
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(
                hoveredFolder: _hoveredTargetNode?.position,
              ),
            ),
          ),

          // Main Nodes canvas
          if (!_loading && _error == null)
            Positioned.fill(
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: CustomPaint(
                  painter: _CelestialPainter(
                    nodes: _nodes,
                    draggedNode: _draggedNode,
                    hoveredFolder: _hoveredTargetNode,
                    center: Offset(size.width / 2, size.height / 2 - 40),
                  ),
                ),
              ),
            ),

          // Touch tap overlay mappings
          if (!_loading && _error == null)
            ..._nodes.map((node) {
              return Positioned(
                left: node.position.dx - node.radius - 10,
                top: node.position.dy - node.radius - 10,
                child: GestureDetector(
                  onTap: () => _onNodeTap(node),
                  onDoubleTap: () => _onNodeDoubleTap(node),
                  child: Container(
                    width: node.radius * 2 + 20,
                    height: node.radius * 2 + 20,
                    color: Colors.transparent,
                  ),
                ),
              );
            }).toList(),

          // Title & Back controls
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              children: [
                if (_currentPath != '/' && _currentPath != '')
                  GestureDetector(
                    onTap: _navigateUp,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: AetheraTheme.glassDecoration(opacity: 0.1),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 16),
                    ),
                  ),
                if (_currentPath != '/' && _currentPath != '') const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantum Space',
                        style: AetheraTheme.neonTextStyle(fontSize: 18, color: AetheraTheme.neonPurple, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentPath.replaceFirst(Directory.systemTemp.parent.path, '~'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'Menlo'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Hover guidelines indicator
          if (_hoveredTargetNode != null && _draggedNode != null)
            Positioned(
              left: 20,
              right: 20,
              top: 110,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: AetheraTheme.glassDecoration(opacity: 0.15, borderOpacity: 0.2, radius: 12, glowOpacity: 0.1),
                child: Center(
                  child: Text(
                    'TIÊM LIÊN KẾT: ${_draggedNode!.item.name} ➔ ${_hoveredTargetNode!.item.name}',
                    style: const TextStyle(color: AetheraTheme.neonCyan, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: AetheraTheme.neonPurple),
            ),

          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AetheraTheme.neonRed, size: 64),
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AetheraTheme.neonPurple),
                      onPressed: _navigateUp,
                      child: const Text('Back up', style: TextStyle(color: Colors.white)),
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

// ─── GRID PAINTER ──────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  final Offset? hoveredFolder;

  _GridPainter({this.hoveredFolder});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 0.5;

    // Draw coordinate lines
    final step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Gravity pull warp distortion around hovered folder
    if (hoveredFolder != null) {
      final warpPaint = Paint()
        ..color = AetheraTheme.neonCyan.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      canvas.drawCircle(hoveredFolder!, 40, warpPaint);
      canvas.drawCircle(hoveredFolder!, 60, warpPaint..color = AetheraTheme.neonCyan.withOpacity(0.03));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─── CELESTIAL PAINTER ──────────────────────────────────────────────────────

class _CelestialPainter extends CustomPainter {
  final List<CelestialNode> nodes;
  final CelestialNode? draggedNode;
  final CelestialNode? hoveredFolder;
  final Offset center;

  _CelestialPainter({
    required this.nodes,
    required this.draggedNode,
    required this.hoveredFolder,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw gravitational orbit rings
    final orbitPaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final node in nodes) {
      if (node.item.isDirectory) {
        // Orbit ring for folder
        canvas.drawCircle(center, node.orbitRadius, orbitPaint);
      }
    }

    // 2. Draw connections (spring loops) from dragged node to hovered folder
    if (draggedNode != null && hoveredFolder != null) {
      final linkPaint = Paint()
        ..color = AetheraTheme.neonCyan.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      // Draw dotted connection
      final start = draggedNode!.position;
      final end = hoveredFolder!.position;
      final points = 10;
      for (int i = 0; i <= points; i++) {
        if (i % 2 == 0) continue;
        final p1 = Offset.lerp(start, end, i / points)!;
        final p2 = Offset.lerp(start, end, (i + 1) / points)!;
        canvas.drawLine(p1, p2, linkPaint);
      }
    }

    // 3. Draw Nodes
    final nodePaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final node in nodes) {
      final isHovered = node == hoveredFolder;

      // Glow Aura shadow
      nodePaint.color = node.glowColor.withOpacity(0.15);
      canvas.drawCircle(node.position, node.radius + 12, nodePaint);

      // Main planet fill
      nodePaint.color = node.item.isDirectory 
          ? AetheraTheme.darkBlue 
          : Color.lerp(AetheraTheme.darkBlue, node.glowColor, 0.25)!;
      canvas.drawCircle(node.position, node.radius, nodePaint);

      // Stroke halo outline
      strokePaint.color = isHovered 
          ? AetheraTheme.neonCyan 
          : node.glowColor.withOpacity(0.8);
      strokePaint.strokeWidth = isHovered ? 2.5 : 1.5;
      canvas.drawCircle(node.position, node.radius, strokePaint);

      // Draw celestial structures for Folders (suns have dynamic rings)
      if (node.item.isDirectory) {
        final ringPaint = Paint()
          ..color = node.glowColor.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(node.position, node.radius + 6, ringPaint);
      }

      // 4. Node text label (Reality Matrix tag)
      final textPainter = TextPainter(
        text: TextSpan(
          text: node.item.name,
          style: TextStyle(
            color: Colors.white.withOpacity(node.isDragging ? 0.9 : 0.65),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 80);
      
      textPainter.paint(
        canvas,
        Offset(
          node.position.dx - textPainter.width / 2,
          node.position.dy + node.radius + 8,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
