import 'package:flutter/material.dart';

/// Bottom sheet hành động cho file/folder (long press)
class FileActionSheet extends StatelessWidget {
  final String name;
  final bool isDirectory;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;
  final VoidCallback? onCopyPath;
  final VoidCallback? onInfo;
  final VoidCallback? onOpen;

  const FileActionSheet({
    super.key,
    required this.name,
    required this.isDirectory,
    this.onDelete,
    this.onRename,
    this.onCopyPath,
    this.onInfo,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Tên file
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Icon(
                  isDirectory ? Icons.folder_rounded : Icons.insert_drive_file_rounded,
                  color: isDirectory ? const Color(0xFFFFB74D) : Colors.white60,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          // Actions
          if (onOpen != null)
            _ActionTile(
              icon: Icons.open_in_new_rounded,
              label: 'Mở file',
              color: const Color(0xFF4FC3F7),
              onTap: () { Navigator.pop(context); onOpen!(); },
            ),
          _ActionTile(
            icon: Icons.copy_rounded,
            label: 'Sao chép đường dẫn',
            color: const Color(0xFF80CBC4),
            onTap: () { Navigator.pop(context); onCopyPath?.call(); },
          ),
          _ActionTile(
            icon: Icons.drive_file_rename_outline_rounded,
            label: 'Đổi tên',
            color: const Color(0xFF90CAF9),
            onTap: () { Navigator.pop(context); onRename?.call(); },
          ),
          _ActionTile(
            icon: Icons.info_outline_rounded,
            label: 'Thông tin',
            color: Colors.white60,
            onTap: () { Navigator.pop(context); onInfo?.call(); },
          ),
          _ActionTile(
            icon: Icons.delete_outline_rounded,
            label: 'Xóa',
            color: const Color(0xFFEF5350),
            onTap: () { Navigator.pop(context); onDelete?.call(); },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: color == const Color(0xFFEF5350) ? color : Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
