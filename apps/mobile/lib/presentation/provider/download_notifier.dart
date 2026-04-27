import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entity/remote_book.dart';
import 'catalog_provider.dart';

part 'download_notifier.g.dart';

sealed class DownloadState {
  const DownloadState();
}

class DownloadIdle extends DownloadState {
  const DownloadIdle();
}

class DownloadInProgress extends DownloadState {
  const DownloadInProgress(this.progress);
  final double progress;
}

class DownloadDone extends DownloadState {
  const DownloadDone();
}

class DownloadError extends DownloadState {
  const DownloadError(this.message);
  final String message;
}

@riverpod
class DownloadNotifier extends _$DownloadNotifier {
  @override
  Future<DownloadState> build(String bookId) async {
    final repo = ref.read(bookDownloadRepositoryProvider);
    final done = await repo.isDownloaded(bookId);
    return done ? const DownloadDone() : const DownloadIdle();
  }

  Future<void> download(RemoteBook book) async {
    final repo = ref.read(bookDownloadRepositoryProvider);
    state = const AsyncData(DownloadInProgress(0));
    try {
      await for (final progress in repo.downloadBook(book)) {
        state = AsyncData(DownloadInProgress(progress));
      }
      state = const AsyncData(DownloadDone());
      // ダウンロード済み本リストを更新
      ref.invalidate(downloadedBooksProvider);
    } catch (e) {
      state = AsyncData(DownloadError(e.toString()));
    }
  }

  Future<void> delete(String bookId) async {
    final repo = ref.read(bookDownloadRepositoryProvider);
    await repo.deleteBook(bookId);
    state = const AsyncData(DownloadIdle());
    ref.invalidate(downloadedBooksProvider);
  }
}
