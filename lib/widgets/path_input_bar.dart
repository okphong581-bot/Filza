import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Thanh nhập đường dẫn + breadcrumb navigation
class PathInputBar extends StatefulWidget {
  final String currentPath;
  final ValueChanged<String> onPathChanged;

  const PathInputBar({
    super.key,
    required this.currentPath,
    required this.onPathChanged,
  });

  @override
  State<PathInputBar> createState() => _PathInputBarState();
}

class _PathInputBarState extends State<PathInputBar> {
  bool _isEditing = false;
  late TextEditingController _ctrl;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentPath);
  }

  @override
  void didUpdateWidget(PathInputBar old) {
    super.didUpdateWidget(old);
    if (old.currentPath != widget.currentPath && !_isEditing) {
      _ctrl.text = widget.currentPath;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() => _isEditing = true);
    _ctrl.text = widget.currentPath;
    _focusNode.requestFocus();
    _ctrl.selectAll();
  }

  void _submitPath() {
    final path = _ctrl.text.trim();
    if (path.isNotEmpty) {
      widget.onPathChanged(path);
    }
    setState(() => _isEditing = false);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isEditing
              ? const Color(0xFF7C3AED)
              : Colors.white.withOpacity(0.08),
          width: _isEditing ? 1.5 : 1,
        ),
        boxShadow: _isEditing
            ? [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.25),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : [],
      ),
      child: _isEditing ? _buildEditMode() : _buildDisplayMode(),
    );
  }

  Widget _buildDisplayMode() {
    return GestureDetector(
      onTap: _startEditing,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.folder_open_rounded,
              color: const Color(0xFF7C3AED),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  widget.currentPath.isEmpty ? '/' : widget.currentPath,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontFamily: 'Menlo',
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.edit_rounded,
              color: Colors.white.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditMode() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.terminal_rounded,
            color: const Color(0xFF7C3AED),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _ctrl,
              focusNode: _focusNode,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontFamily: 'Menlo',
                letterSpacing: 0.2,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: '/var/mobile/Documents',
                hintStyle: TextStyle(
                  color: Colors.white38,
                  fontSize: 13.5,
                  fontFamily: 'Menlo',
                ),
              ),
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => _submitPath(),
            ),
          ),
          GestureDetector(
            onTap: _submitPath,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Go',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
