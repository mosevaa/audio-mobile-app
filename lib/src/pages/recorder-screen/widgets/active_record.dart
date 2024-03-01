

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lanius/src/features/recorder/di.dart';
import 'package:lanius/src/pages/recorder-screen/widgets/record_time.dart';

class ActiveRecord extends ConsumerWidget {
  const ActiveRecord({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(recorderManagerProvider);
    final ongoingProvider = ref.watch(ongoingRecordProviderProvider);

    final startAt = ongoingProvider.ongoingRecord?.startAt;

    if (startAt == null) return const SizedBox();

    return Column(
      children: [
        const Text(
          'Идет запись',
          style: TextStyle(
            fontFamily: 'Commissioner',
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        RecordTime(startAt: startAt),
        TextButton(
          child: const Text(
            'Остановить',
            style: TextStyle(fontFamily: 'Commissioner'),
          ),
          onPressed: () {
            manager.stop();
          },
        )
      ],
    );
  }
}