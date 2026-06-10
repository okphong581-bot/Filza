import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../models/file_item.dart';
import '../services/file_service.dart';
import '../widgets/file_list_tile.dart';
import '../widgets/path_input_bar.dart';
import '../widgets/action_sheet.dart';
import '../widgets/upload_fab.dart';

class FileManagerScreen extends StatefulWidget {
  const FileManagerScreen({super.key});

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  final FileService _svc = FileService();
  final _dateFormat = DateFormat('dd/MM/yy HH:mm');

  String _currentPath = '';
  List<FileItem> _items = [];
  List<FileItem> _filtered = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initPath();
  }

  Future<void> _initPath() async {
    final docPath = await _svc.getDefaultPath();
    setState(() => _currentPath = docPath);
    await _loadDirectory(docPath);
  }

  Future<void> _loadDirectory(String path) async {
    setState(() { _loading = true; _error = null; });
    try {
      final items = await _svc.listDirectory(path);
      setState(() {
        _currentPath = path;
        _items = items;
        _filtered = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
        _items = [];
        _filtered = [];
      });
    }
  }

  void _onSearch(String q) {
    setState(() {
      _searchQuery = q;
      _filtered = q.isEmpty
          ? _items
          : _items.where((f) => f.name.toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  void _navigateTo(FileItem item) {
    if (item.isDirectory) {
      _loadDirectory(item.path);
    } else {
      OpenFile.open(item.path);
    }
  }

  void _navigateUp() {
    final parent = _svc.getParentPath(_currentPath);
    _loadDirectory(parent);
  }

  // ── UPLOAD FILE ──────────────────────────────────────────
  Future<void> _uploadSingleFile() async {
    _showToast('Chọn file để tiêm vào\n$_currentPath', isInfo: true);
    try {
      final item = await _svc.pickAndInjectFile(_currentPath);
      _showToast('✅ Đã tiêm: ${item.name}');
      await _loadDirectory(_currentPath);
    } catch (e) {
      _showToast('❌ ${e.toString().replaceFirst('Exception: ', '')}',
          isError: true);
    }
  }

  Future<void> _uploadMultipleFiles() async {
    _showToast('Chọn nhiều file để tiêm vào\n$_currentPath', isInfo: true);
    try {
      final items = await _svc.pickAndInjectMultiple(_currentPath);
      if (items.isEmpty) {
        _showToast('Không có file nào được chọn');
      } else {
        _showToast('✅ Đã tiêm ${items.length} file');
        await _loadDirectory(_currentPath);
      }
    } catch (e) {
      _showToast('❌ ${e.toString().replaceFirst('Exception: ', '')}',
          isError: true);
    }
  }

  // ── TẠO THƯ MỤC ─────────────────────────────────────────
  Future<void> _createFolder() async {
    String? folderName;
    await showDialog(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tạo thư mục mới',
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: ctrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tên thư mục',
              hintStyle: TextStyle(color: Colors.white38),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF7C3AED)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            autofocus: true,
            onSubmitted: (v) {
              folderName = v;
              Navigator.pop(ctx);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Hủy', style: TextStyle(color: Colors.white38)),
            ),
            TextButton(
              onPressed: () {
                folderName = ctrl.text;
                Navigator.pop(ctx);
              },
              child: const Text('Tạo',
                  style: TextStyle(color: Color(0xFF7C3AED))),
            ),
          ],
        );
      },
    );
    if (folderName != null && folderName!.isNotEmpty) {
      final ok = await _svc.createDirectory('$_currentPath/$folderName');
      _showToast(ok ? '✅ Đã tạo thư mục: $folderName' : '❌ Không tạo được');
      if (ok) await _loadDirectory(_currentPath);
    }
  }

  // ── XÓA ──────────────────────────────────────────────────
  Future<void> _deleteItem(FileItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa',
            style: TextStyle(color: Colors.white)),
        content: Text('Xóa "${item.name}"?',
            style: TextStyle(color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Hủy', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa',
                style: TextStyle(color: Color(0xFFEF5350))),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final ok = await _svc.deleteItem(item.path);
      _showToast(ok ? '✅ Đã xóa: ${item.name}' : '❌ Không xóa được',
          isError: !ok);
      if (ok) await _loadDirectory(_currentPath);
    }
  }

  // ── RENAME ───────────────────────────────────────────────
  Future<void> _renameItem(FileItem item) async {
    String? newName;
    await showDialog(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: item.name);
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Đổi tên',
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: ctrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF7C3AED)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            autofocus: true,
            onSubmitted: (v) { newName = v; Navigator.pop(ctx); },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx),
                child: Text('Hủy', style: TextStyle(color: Colors.white38))),
            TextButton(onPressed: () { newName = ctrl.text; Navigator.pop(ctx); },
                child: const Text('Đổi tên',
                    style: TextStyle(color: Color(0xFF7C3AED)))),
          ],
        );
      },
    );
    if (newName != null && newName!.isNotEmpty && newName != item.name) {
      final ok = await _svc.renameItem(item.path, newName!);
      _showToast(ok ? '✅ Đã đổi tên' : '❌ Không đổi được', isError: !ok);
      if (ok) await _loadDirectory(_currentPath);
    }
  }

  // ── ACTION SHEET ──────────────────────────────────────────
  void _showActionSheet(FileItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => FileActionSheet(
        name: item.name,
        isDirectory: item.isDirectory,
        onOpen: item.isDirectory ? null : () => OpenFile.open(item.path),
        onCopyPath: () {
          Clipboard.setData(ClipboardData(text: item.path));
          _showToast('✅ Đã copy đường dẫn');
        },
        onRename: () => _renameItem(item),
        onDelete: () => _deleteItem(item),
        onInfo: () => _showInfoDialog(item),
      ),
    );
  }

  void _showInfoDialog(FileItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(item.isDirectory ? Icons.folder_rounded : Icons.insert_drive_file_rounded,
                color: item.isDirectory ? const Color(0xFFFFB74D) : Colors.white60),
            const SizedBox(width: 8),
            Expanded(child: Text(item.name,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                maxLines: 2, overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Loại', item.isDirectory ? 'Thư mục' : 'File ${item.extension.toUpperCase()}'),
            _infoRow('Kích thước', _svc.formatSize(item.sizeBytes)),
            _infoRow('Sửa đổi', _dateFormat.format(item.lastModified)),
            _infoRow('Đường dẫn', item.path),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng', style: TextStyle(color: Color(0xFF7C3AED)))),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 3),
          SelectableText(value,
              style: const TextStyle(color: Colors.white, fontSize: 13.5)),
        ],
      ),
    );
  }

  // ── TOAST ─────────────────────────────────────────────────
  void _showToast(String msg, {bool isError = false, bool isInfo = false}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(builder: (_) => _ToastWidget(
      message: msg,
      isError: isError,
      isInfo: isInfo,
      onDone: () => entry.remove(),
    ));
    overlay.insert(entry);
  }

  // ── BREADCRUMB ────────────────────────────────────────────
  Widget _buildBreadcrumb() {
    final crumbs = _svc.getBreadcrumbs(_currentPath);
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: crumbs.length,
        separatorBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.chevron_right_rounded,
              color: Colors.white24, size: 16),
        ),
        itemBuilder: (_, i) {
          final crumb = crumbs[i];
          final isLast = i == crumbs.length - 1;
          return GestureDetector(
            onTap: isLast ? null : () => _loadDirectory(crumb['path']!),
            child: Center(
              child: Text(
                crumb['label']!,
                style: TextStyle(
                  color: isLast ? const Color(0xFF7C3AED) : Colors.white38,
                  fontSize: 12.5,
                  fontFamily: 'Menlo',
                  fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── QUICK PATH MENU ───────────────────────────────────────
  void _showQuickPaths() async {
    final docPath = await _svc.getDefaultPath();
    final paths = _svc.getQuickPaths();
    paths[0]['path'] = docPath;
    paths[0]['label'] = 'App Documents';

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Quick Access',
                    style: TextStyle(color: Colors.white,
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            ...paths.map((p) => InkWell(
              onTap: () {
                Navigator.pop(context);
                _loadDirectory(p['path']!);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.folder_special_rounded,
                        color: const Color(0xFF7C3AED), size: 20),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['label']!,
                            style: const TextStyle(color: Colors.white, fontSize: 14)),
                        Text(p['path']!,
                            style: TextStyle(color: Colors.white38, fontSize: 11,
                                fontFamily: 'Menlo')),
                      ],
                    ),
                  ],
                ),
              ),
            )).toList(),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
          ],
        ),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  // Nút back
                  if (_currentPath != '/')
                    GestureDetector(
                      onTap: _navigateUp,
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white70, size: 17),
                      ),
                    ),
                  if (_currentPath != '/') const SizedBox(width: 10),
                  Expanded(
                    child: Text('Ha File Manager',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        )),
                  ),
                  // Search
                  GestureDetector(
                    onTap: () => setState(() {
                      _showSearch = !_showSearch;
                      if (!_showSearch) {
                        _searchCtrl.clear();
                        _onSearch('');
                      }
                    }),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: _showSearch
                            ? const Color(0xFF7C3AED).withOpacity(0.2)
                            : Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _showSearch ? Icons.search_off_rounded : Icons.search_rounded,
                        color: _showSearch ? const Color(0xFF7C3AED) : Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Quick paths
                  GestureDetector(
                    onTap: _showQuickPaths,
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bookmark_rounded,
                          color: Colors.white70, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Refresh
                  GestureDetector(
                    onTap: () => _loadDirectory(_currentPath),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.refresh_rounded,
                          color: Colors.white70, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Bar ──
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearch,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm file...',
                    hintStyle: TextStyle(color: Colors.white38),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF1C1C2E),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.3),
              ),

            // ── Path Input ──
            PathInputBar(
              currentPath: _currentPath,
              onPathChanged: _loadDirectory,
            ),

            // ── Breadcrumb ──
            _buildBreadcrumb(),
            const SizedBox(height: 8),

            // ── Status Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Text(
                    _loading
                        ? 'Đang tải...'
                        : _error != null
                            ? ''
                            : '${_filtered.length} mục',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),

            // ── File List ──
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF7C3AED)))
                  : _error != null
                      ? _buildErrorView()
                      : _filtered.isEmpty
                          ? _buildEmptyView()
                          : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 120),
                              itemCount: _filtered.length,
                              separatorBuilder: (_, __) => Divider(
                                color: Colors.white.withOpacity(0.04),
                                height: 1,
                                indent: 70,
                              ),
                              itemBuilder: (ctx, i) {
                                final item = _filtered[i];
                                return FileListTile(
                                  name: item.name,
                                  isDirectory: item.isDirectory,
                                  iconType: item.iconAsset,
                                  size: _svc.formatSize(item.sizeBytes),
                                  date: _dateFormat.format(item.lastModified),
                                  onTap: () => _navigateTo(item),
                                  onLongPress: () => _showActionSheet(item),
                                ).animate()
                                  .fadeIn(duration: 180.ms, delay: (i * 20).ms)
                                  .slideX(begin: 0.05, duration: 180.ms,
                                      delay: (i * 20).ms);
                              },
                            ),
            ),
          ],
        ),
      ),
      // ── FAB ──
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: UploadFab(
          onUploadFile: _uploadSingleFile,
          onUploadMultiple: _uploadMultipleFiles,
          onCreateFolder: _createFolder,
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEF5350).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.lock_rounded,
                  color: Color(0xFFEF5350), size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Không thể truy cập',
                style: TextStyle(color: Colors.white,
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_error!,
                style: TextStyle(color: Colors.white38, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => _loadDirectory(_svc.getParentPath(_currentPath)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.4)),
                ),
                child: const Text('Quay lại',
                    style: TextStyle(color: Color(0xFF7C3AED), fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open_rounded,
              color: Colors.white.withOpacity(0.15), size: 72),
          const SizedBox(height: 16),
          Text('Thư mục trống',
              style: TextStyle(color: Colors.white38, fontSize: 16)),
        ],
      ),
    );
  }
}

// ─── Toast Overlay ───────────────────────────────────────────────────────────
class _ToastWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final bool isInfo;
  final VoidCallback onDone;

  const _ToastWidget({
    required this.message,
    required this.isError,
    required this.isInfo,
    required this.onDone,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 300.ms);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _ctrl.forward();
    Future.delayed(2500.ms, () {
      if (mounted) _ctrl.reverse().then((_) => widget.onDone());
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: ScaleTransition(
        scale: _anim,
        child: FadeTransition(
          opacity: _anim,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isError
                  ? const Color(0xFFEF5350).withOpacity(0.9)
                  : widget.isInfo
                      ? const Color(0xFF1C1C2E).withOpacity(0.95)
                      : const Color(0xFF2D1B69).withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isError
                    ? Colors.red.withOpacity(0.3)
                    : const Color(0xFF7C3AED).withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              widget.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
