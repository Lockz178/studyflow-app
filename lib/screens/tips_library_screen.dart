import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/mock_data_service.dart';
import '../widgets/study_tip_list_tile.dart';

/// Paginated tips list with infinite scroll (loads one page at a time).
class TipsLibraryScreen extends StatefulWidget {
  const TipsLibraryScreen({super.key});

  @override
  State<TipsLibraryScreen> createState() => _TipsLibraryScreenState();
}

class _TipsLibraryScreenState extends State<TipsLibraryScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<int> _loadedIndices = [];

  int _page = 0;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  static const int _pageSize = 2;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_maybeLoadMore);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNextPage());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_maybeLoadMore);
    _scrollController.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_loading || !_hasMore) return;

    final all = MockDataService.allLearningTips;
    if (all.isEmpty) {
      setState(() {
        _hasMore = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await Future<void>.delayed(const Duration(milliseconds: 280));
      final start = _page * _pageSize;
      if (start >= all.length) {
        setState(() {
          _hasMore = false;
          _loading = false;
        });
        return;
      }
      final end = (start + _pageSize) > all.length ? all.length : start + _pageSize;
      for (var i = start; i < end; i++) {
        _loadedIndices.add(i);
      }
      _page++;
      if (end >= all.length) {
        _hasMore = false;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = MockDataService.allLearningTips;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Tips library',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _page = 0;
            _loadedIndices.clear();
            _hasMore = true;
            _error = null;
          });
          await _loadNextPage();
        },
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              'Scroll to load more tips in small batches. Images are loaded from the network with a local icon fallback.',
              style: TextStyle(fontSize: 14, height: 1.45, color: textSecondary),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Something went wrong',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_error!),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() => _error = null);
                          _loadNextPage();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            if (all.isEmpty && !_loading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Text(
                    'No tips in the seed data yet.',
                    style: TextStyle(color: textSecondary),
                  ),
                ),
              )
            else
              ..._loadedIndices.map(
                (i) => StudyTipListTile(
                  tipText: all[i],
                  imageSeedIndex: i,
                ),
              ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!_hasMore && _loadedIndices.isNotEmpty && !_loading)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    'You reached the end.',
                    style: TextStyle(color: textSecondary, fontSize: 13),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
