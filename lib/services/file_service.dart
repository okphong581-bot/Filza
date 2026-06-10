import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/file_item.dart';

/// Service xử lý toàn bộ thao tác file/thư mục
class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  // ─────────────────────────────────────────
  // ĐƯỜNG DẪN MẶC ĐỊNH
  // ─────────────────────────────────────────

  /// Lấy thư mục Documents của app (sandbox-safe)
  Future<String> getDefaultPath() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    } catch (_) {
      return '/';
    }
  }

  /// Danh sách quick-access paths
  List<Map<String, String>> getQuickPaths() {
    return [
      {'label': 'App Documents', 'path': ''},  // fill async
      {'label': '/var/mobile/Documents', 'path': '/var/mobile/Documents'},
      {'label': '/var/mobile/Media', 'path': '/var/mobile/Media'},
      {'label': '/var/mobile/Library', 'path': '/var/mobile/Library'},
      {'label': '/tmp', 'path': '/tmp'},
      {'label': '/var/mobile', 'path': '/var/mobile'},
      {'label': '/', 'path': '/'},
    ];
  }

  // ─────────────────────────────────────────
  // ĐỌC THƯ MỤC
  // ─────────────────────────────────────────

  /// Liệt kê nội dung một thư mục theo đường dẫn
  Future<List<FileItem>> listDirectory(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        throw Exception('Thư mục không tồn tại: $path');
      }

      final List<FileItem> items = [];
      final entities = dir.listSync(followLinks: false);

      for (final entity in entities) {
        try {
          final stat = await entity.stat();
          final isDir = entity is Directory;
          items.add(FileItem.fromPath(
            path: entity.path,
            isDirectory: isDir,
            sizeBytes: stat.size,
            lastModified: stat.modified,
          ));
        } catch (_) {
          // Bỏ qua file không đọc được (permission)
        }
      }

      // Sắp xếp: thư mục trước, sau đó file theo tên
      items.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return items;
    } on FileSystemException catch (e) {
      throw Exception('Không có quyền truy cập: ${e.message}');
    }
  }

  // ─────────────────────────────────────────
  // UPLOAD / TIÊM FILE
  // ─────────────────────────────────────────

  /// Chọn file từ thiết bị và copy vào thư mục đích
  /// Trả về [FileItem] đã copy hoặc throw exception
  Future<FileItem> pickAndInjectFile(String destDirectory) async {
    // Kiểm tra thư mục đích tồn tại
    final destDir = Directory(destDirectory);
    if (!await destDir.exists()) {
      // Thử tạo thư mục nếu chưa có
      await destDir.create(recursive: true);
    }

    // Mở file picker
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
      withData: false,
      withReadStream: false,
    );

    if (result == null || result.files.isEmpty) {
      throw Exception('Không có file nào được chọn');
    }

    final picked = result.files.first;
    if (picked.path == null) {
      throw Exception('Không lấy được đường dẫn file');
    }

    final sourceFile = File(picked.path!);
    final destPath = '$destDirectory/${picked.name}';
    final destFile = File(destPath);

    // Copy file vào đích
    await sourceFile.copy(destPath);

    final stat = await destFile.stat();
    return FileItem.fromPath(
      path: destPath,
      isDirectory: false,
      sizeBytes: stat.size,
      lastModified: stat.modified,
    );
  }

  /// Copy nhiều file cùng lúc
  Future<List<FileItem>> pickAndInjectMultiple(String destDirectory) async {
    final destDir = Directory(destDirectory);
    if (!await destDir.exists()) {
      await destDir.create(recursive: true);
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      throw Exception('Không có file nào được chọn');
    }

    final List<FileItem> injected = [];
    for (final picked in result.files) {
      if (picked.path == null) continue;
      try {
        final sourceFile = File(picked.path!);
        final destPath = '$destDirectory/${picked.name}';
        await sourceFile.copy(destPath);
        final stat = await File(destPath).stat();
        injected.add(FileItem.fromPath(
          path: destPath,
          isDirectory: false,
          sizeBytes: stat.size,
          lastModified: stat.modified,
        ));
      } catch (_) {
        // tiếp tục với file tiếp theo
      }
    }
    return injected;
  }

  // ─────────────────────────────────────────
  // TẠO / XÓA
  // ─────────────────────────────────────────

  /// Tạo thư mục mới
  Future<bool> createDirectory(String path) async {
    try {
      await Directory(path).create(recursive: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Xóa file hoặc thư mục
  Future<bool> deleteItem(String path) async {
    try {
      final type = await FileSystemEntity.type(path);
      if (type == FileSystemEntityType.directory) {
        await Directory(path).delete(recursive: true);
      } else {
        await File(path).delete();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Đổi tên file/thư mục
  Future<bool> renameItem(String oldPath, String newName) async {
    try {
      final parent = oldPath.substring(0, oldPath.lastIndexOf('/'));
      final newPath = '$parent/$newName';
      await FileSystemEntity.isDirectory(oldPath)
          ? await Directory(oldPath).rename(newPath)
          : await File(oldPath).rename(newPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────
  // TIỆN ÍCH
  // ─────────────────────────────────────────

  /// Kiểm tra đường dẫn có tồn tại và có quyền đọc không
  Future<Map<String, bool>> checkPath(String path) async {
    final exists = await Directory(path).exists() || await File(path).exists();
    bool readable = false;
    bool writable = false;
    if (exists) {
      try {
        if (await Directory(path).exists()) {
          await Directory(path).list().first;
          readable = true;
          // Test write
          final testFile = File('$path/.ha_write_test');
          await testFile.writeAsString('test');
          await testFile.delete();
          writable = true;
        }
      } catch (_) {}
    }
    return {'exists': exists, 'readable': readable, 'writable': writable};
  }

  /// Format kích thước file sang string dễ đọc
  String formatSize(int bytes) {
    if (bytes < 0) return '—';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Lấy thư mục cha
  String getParentPath(String path) {
    if (path == '/') return '/';
    final parts = path.split('/');
    if (parts.length <= 2) return '/';
    parts.removeLast();
    return parts.join('/');
  }

  /// Tách breadcrumb từ path
  List<Map<String, String>> getBreadcrumbs(String path) {
    if (path.isEmpty) return [];
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    final List<Map<String, String>> crumbs = [
      {'label': '/', 'path': '/'}
    ];
    String current = '';
    for (final part in parts) {
      current += '/$part';
      crumbs.add({'label': part, 'path': current});
    }
    return crumbs;
  }
}
