import 'package:azkary/azkary.dart';
import 'package:flutter/material.dart';

import '../core/snack_error.dart';
import '../widgets/batch_progress_card.dart';
import '../widgets/category_tile.dart';
import '../widgets/retry_view.dart';
import 'category_azkar_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<ZekrCategory> _categories = [];
  String? _error;
  bool _loading = true;

  AllAudiosDownloadProgress? _batchProgress;
  bool _batchRunning = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await Azkary.instance.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = list;
        _loading = false;
      });
    } on AzkaryException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.developerMessage;
        _loading = false;
      });
    }
  }

  Future<void> _downloadAll() async {
    if (_batchRunning) return;
    setState(() {
      _batchRunning = true;
      _batchProgress = null;
    });
    try {
      await Azkary.instance.downloadAllAudios(
        onProgress: (p) {
          if (mounted) setState(() => _batchProgress = p);
        },
      );
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اكتمل تنزيل الأصوات'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) snackError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _batchRunning = false;
          _batchProgress = null;
        });
      }
    }
  }

  Future<void> _cancelAllDownloads() async {
    try {
      final n = await Azkary.instance.cancelAllDownloads();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('أُلغي $n تنزيلاً')),
      );
    } catch (e) {
      if (mounted) snackError(context, e);
    }
  }

  void _openCategory(ZekrCategory category) {
    Navigator.of(context)
        .push<void>(
          MaterialPageRoute<void>(
            builder: (_) => CategoryAzkarPage(category: category),
          ),
        )
        .then((_) {
      if (mounted) _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأذكار'),
          actions: [
            if (_batchRunning)
              IconButton(
                tooltip: 'إلغاء التنزيلات',
                onPressed: _cancelAllDownloads,
                icon: const Icon(Icons.stop_circle_outlined),
              ),
            IconButton(
              tooltip: 'تنزيل كل الأصوات',
              onPressed: _batchRunning ? null : _downloadAll,
              icon: _batchRunning
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_download_rounded),
            ),
            IconButton(
              tooltip: 'تحديث',
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? RetryView(message: _error!, onRetry: _load)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      if (_batchProgress != null) ...[
                        BatchProgressCard(progress: _batchProgress!),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        '${_categories.length} فئات',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ..._categories.map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: CategoryTile(
                            category: cat,
                            onTap: () => _openCategory(cat),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
