/// Model đại diện cho một file hoặc thư mục trong hệ thống
class FileItem {
  final String path;
  final String name;
  final bool isDirectory;
  final int sizeBytes;
  final DateTime lastModified;
  final String extension;

  const FileItem({
    required this.path,
    required this.name,
    required this.isDirectory,
    required this.sizeBytes,
    required this.lastModified,
    required this.extension,
  });

  /// Tạo FileItem từ đường dẫn
  factory FileItem.fromPath({
    required String path,
    required bool isDirectory,
    required int sizeBytes,
    required DateTime lastModified,
  }) {
    final name = path.split('/').last;
    final ext = isDirectory ? '' : (name.contains('.') ? name.split('.').last.toLowerCase() : '');
    return FileItem(
      path: path,
      name: name,
      isDirectory: isDirectory,
      sizeBytes: sizeBytes,
      lastModified: lastModified,
      extension: ext,
    );
  }

  /// Lấy icon theo loại file
  String get iconAsset {
    if (isDirectory) return 'folder';
    switch (extension) {
      case 'pdf':
        return 'pdf';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'heic':
        return 'image';
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
        return 'video';
      case 'mp3':
      case 'm4a':
      case 'aac':
      case 'wav':
        return 'audio';
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return 'archive';
      case 'dart':
      case 'swift':
      case 'py':
      case 'js':
      case 'ts':
      case 'json':
      case 'xml':
      case 'plist':
      case 'yaml':
      case 'yml':
        return 'code';
      case 'txt':
      case 'md':
      case 'log':
        return 'text';
      case 'ipa':
      case 'deb':
      case 'dylib':
        return 'package';
      default:
        return 'file';
    }
  }
}
