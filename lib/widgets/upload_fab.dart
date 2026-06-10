import 'package:flutter/material.dart';

/// FAB upload với menu mở rộng
class UploadFab extends StatefulWidget {
  final VoidCallback onUploadFile;
  final VoidCallback onUploadMultiple;
  final VoidCallback onCreateFolder;

  const UploadFab({
    super.key,
    required this.onUploadFile,
    required this.onUploadMultiple,
    required this.onCreateFolder,
  });

  @override
  State<UploadFab> createState() => _UploadFabState();
}

class _UploadFabState extends State<UploadFab>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animCtrl;
  late Animation<double> _rotateAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _rotateAnim = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _animCtrl.forward();
    } else {
      _animCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Sub-FABs
        FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SubFab(
                icon: Icons.create_new_folder_rounded,
                label: 'Tạo thư mục',
                color: const Color(0xFFFFB74D),
                onTap: () {
                  _toggle();
                  widget.onCreateFolder();
                },
              ),
              const SizedBox(height: 10),
              _SubFab(
                icon: Icons.file_upload_rounded,
                label: 'Tiêm nhiều file',
                color: const Color(0xFF4FC3F7),
                onTap: () {
                  _toggle();
                  widget.onUploadMultiple();
                },
              ),
              const SizedBox(height: 10),
              _SubFab(
                icon: Icons.upload_file_rounded,
                label: 'Tiêm file',
                color: const Color(0xFFA78BFA),
                onTap: () {
                  _toggle();
                  widget.onUploadFile();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        // Main FAB
        GestureDetector(
          onTap: _toggle,
          child: AnimatedBuilder(
            animation: _animCtrl,
            builder: (_, __) => Transform.rotate(
              angle: _rotateAnim.value * 2 * 3.14159,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  _isExpanded ? Icons.close_rounded : Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubFab extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SubFab({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C2E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              border: Border.all(color: color.withOpacity(0.4), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
        ],
      ),
    );
  }
}
