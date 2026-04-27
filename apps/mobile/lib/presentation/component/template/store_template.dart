import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entity/remote_book.dart';
import '../../../l10n/app_localizations.dart';
import '../../provider/catalog_provider.dart';
import '../../provider/download_notifier.dart';

class StoreTemplate extends ConsumerWidget {
  const StoreTemplate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final catalogAsync = ref.watch(catalogBooksProvider);

    return Scaffold(
      backgroundColor: Colors.amber[50],
      appBar: AppBar(
        backgroundColor: Colors.amber[50],
        elevation: 0,
        title: Text(
          l10n.store,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown[800]),
        ),
        iconTheme: IconThemeData(color: Colors.brown[800]),
      ),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.downloadError)),
        data: (books) {
          if (books.isEmpty) {
            return Center(child: Text(l10n.storeEmpty));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) =>
                _StoreBookCard(book: books[index]),
          );
        },
      ),
    );
  }
}

class _StoreBookCard extends ConsumerWidget {
  const _StoreBookCard({required this.book});

  final RemoteBook book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final downloadAsync = ref.watch(downloadNotifierProvider(book.id));
    final downloadState = downloadAsync.valueOrNull ?? const DownloadIdle();
    final notifier = ref.read(downloadNotifierProvider(book.id).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  book.coverImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.brown[100],
                    child: const Icon(Icons.book, size: 40, color: Colors.brown),
                  ),
                ),
                if (downloadState is DownloadInProgress)
                  _ProgressOverlay(progress: downloadState.progress),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          book.localizedTitle(languageCode),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        _ActionButton(
          state: downloadState,
          l10n: l10n,
          onDownload: () => notifier.download(book),
          onDelete: () => notifier.delete(book.id),
        ),
      ],
    );
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.state,
    required this.l10n,
    required this.onDownload,
    required this.onDelete,
  });

  final DownloadState state;
  final AppLocalizations l10n;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      DownloadIdle() => FilledButton(
          onPressed: onDownload,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size.fromHeight(28),
            textStyle: const TextStyle(fontSize: 12),
          ),
          child: Text(l10n.download),
        ),
      DownloadInProgress() => FilledButton(
          onPressed: null,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size.fromHeight(28),
            textStyle: const TextStyle(fontSize: 12),
          ),
          child: Text(l10n.downloading),
        ),
      DownloadDone() => OutlinedButton(
          onPressed: onDelete,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size.fromHeight(28),
            textStyle: const TextStyle(fontSize: 12),
            foregroundColor: Colors.red,
          ),
          child: Text(l10n.deleteBook),
        ),
      DownloadError() => FilledButton(
          onPressed: onDownload,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size.fromHeight(28),
            backgroundColor: Colors.red,
            textStyle: const TextStyle(fontSize: 12),
          ),
          child: Text(l10n.downloadError),
        ),
    };
  }
}
