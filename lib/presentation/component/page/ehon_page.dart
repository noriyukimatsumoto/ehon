import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../provider/ehon_notifier.dart';
import '../template/finished_template.dart';
import '../template/reading_template.dart';

class EhonPage extends ConsumerWidget {
  const EhonPage({super.key, required this.xmlPath});

  final String xmlPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ehonAsync = ref.watch(ehonNotifierProvider(xmlPath));

    return ehonAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('エラー: $e')),
      ),
      data: (state) {
        if (state.isFinished) {
          return FinishedTemplate(
            onRestart: () =>
                ref.read(ehonNotifierProvider(xmlPath).notifier).restart(),
            onSelectBook: () => context.pop(),
          );
        }
        return ReadingTemplate(
          page: state.currentPage,
          currentIndex: state.currentIndex,
          totalPages: state.pages.length,
          remaining: state.remaining,
        );
      },
    );
  }
}
