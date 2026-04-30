import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entity/remote_book.dart';
import '../../../l10n/app_localizations.dart';
import '../../provider/catalog_provider.dart';
import '../../provider/download_notifier.dart';
import '../atom/book_title_text.dart';

class CatalogTab extends ConsumerWidget {
  const CatalogTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final catalogAsync = ref.watch(catalogBooksProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: Colors.amber[50],
          elevation: 0,
          title: Text(
            l10n.store,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
        ),
        catalogAsync.when(
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SliverFillRemaining(
            child: Center(child: Text(l10n.downloadError)),
          ),
          data: (books) {
            if (books.isEmpty) {
              return SliverFillRemaining(
                child: Center(child: Text(l10n.storeEmpty)),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.83,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _CatalogBookCard(book: books[index]),
                  childCount: books.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CatalogBookCard extends ConsumerStatefulWidget {
  const _CatalogBookCard({required this.book});

  final RemoteBook book;

  @override
  ConsumerState<_CatalogBookCard> createState() => _CatalogBookCardState();
}

class _CatalogBookCardState extends ConsumerState<_CatalogBookCard> {
  bool _openAfterDownload = false;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final downloadAsync = ref.watch(downloadNotifierProvider(widget.book.id));
    final downloadState = downloadAsync.valueOrNull ?? const DownloadIdle();
    final notifier = ref.read(downloadNotifierProvider(widget.book.id).notifier);

    ref.listen(downloadNotifierProvider(widget.book.id), (prev, next) {
      if (!_openAfterDownload) return;
      if (prev?.valueOrNull is DownloadInProgress &&
          next.valueOrNull is DownloadDone) {
        _openAfterDownload = false;
        unawaited(_openBook(context));
      } else if (next.valueOrNull is DownloadError) {
        _openAfterDownload = false;
        unawaited(_openLocalBook(context));
      }
    });

    return GestureDetector(
      onTap: () async {
        if (downloadState is DownloadDone) {
          await _openBook(context);
        } else if (downloadState is DownloadIdle ||
            downloadState is DownloadError) {
          _openAfterDownload = true;
          unawaited(notifier.download(widget.book));
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.book.coverImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.brown[100],
                      child: const Icon(
                        Icons.book,
                        size: 32,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  if (downloadState is DownloadInProgress)
                    _ProgressOverlay(progress: downloadState.progress)
                  else if (downloadState is DownloadIdle)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: _ImageIconButton(
                        icon: Icons.download,
                        color: Colors.orange,
                        onTap: () => notifier.download(widget.book),
                      ),
                    )
                  else if (downloadState is DownloadError)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: _ImageIconButton(
                        icon: Icons.refresh,
                        color: Colors.red,
                        onTap: () => notifier.download(widget.book),
                      ),
                    )
                  else if (downloadState is DownloadDone) ...[
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(3),
                        child: const Icon(
                          Icons.check,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: _ImageIconButton(
                        icon: Icons.delete_outline,
                        color: Colors.red,
                        onTap: () => notifier.delete(widget.book.id),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          BookTitleText(title: widget.book.localizedTitle(languageCode)),
        ],
      ),
    );
  }

  Future<void> _openLocalBook(BuildContext context) async {
    final repo = ref.read(bookDownloadRepositoryProvider);
    final localBook = await repo.getLocalBook(widget.book.id);
    if (context.mounted) {
      unawaited(context.push('/read', extra: localBook.jsonPath));
    }
  }

  Future<void> _openBook(BuildContext context) async {
    final repo = ref.read(bookDownloadRepositoryProvider);
    final localBook = await repo.getLocalBook(widget.book.id);

    if (localBook.version != widget.book.version) {
      _openAfterDownload = true;
      unawaited(
        ref
            .read(downloadNotifierProvider(widget.book.id).notifier)
            .download(widget.book),
      );
      return;
    }

    if (context.mounted) {
      unawaited(context.push('/read', extra: localBook.jsonPath));
    }
  }
}

class _ProgressOverlay extends StatelessWidget {
  const _ProgressOverlay({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black45,
      child: Center(
        child: CircularProgressIndicator(
          value: progress,
          color: Colors.white,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class _ImageIconButton extends StatelessWidget {
  const _ImageIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
