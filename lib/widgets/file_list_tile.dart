import 'package:flutter/material.dart';

/// Tile hiển thị một file hoặc thư mục trong danh sách
class FileListTile extends StatelessWidget {
  final String name;
  final bool isDirectory;
  final String iconType;
  final String size;
  final String date;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const FileListTile({
    super.key,
    required this.name,
    required this.isDirectory,
    required this.iconType,
    required this.size,
    required this.date,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(10),
        splashColor: const Color(0xFF7C3AED).withOpacity(0.2),
        highlightColor: const Color(0xFF7C3AED).withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _iconBg(iconType),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconData(iconType),
                  color: _iconColor(iconType),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Tên + metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDirectory ? date : '$size  ·  $date',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Mũi tên nếu là thư mục
              if (isDirectory)
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.3),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconData(String type) {
    switch (type) {
      case 'folder':
        return Icons.folder_rounded;
      case 'image':
        return Icons.image_rounded;
      case 'video':
        return Icons.video_file_rounded;
      case 'audio':
        return Icons.audio_file_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'archive':
        return Icons.archive_rounded;
      case 'code':
        return Icons.code_rounded;
      case 'text':
        return Icons.article_rounded;
      case 'package':
        return Icons.install_mobile_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'folder':
        return const Color(0xFFFFB74D);
      case 'image':
        return const Color(0xFF4FC3F7);
      case 'video':
        return const Color(0xFFFF8A65);
      case 'audio':
        return const Color(0xFFCE93D8);
      case 'pdf':
        return const Color(0xFFEF5350);
      case 'archive':
        return const Color(0xFFA5D6A7);
      case 'code':
        return const Color(0xFF80CBC4);
      case 'text':
        return const Color(0xFF90CAF9);
      case 'package':
        return const Color(0xFFFFCC02);
      default:
        return Colors.white60;
    }
  }

  Color _iconBg(String type) {
    return _iconColor(type).withOpacity(0.12);
  }
}
