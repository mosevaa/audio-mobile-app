import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lanius/src/features/recorder/di.dart';

class InactiveRecord extends ConsumerWidget {
  const InactiveRecord({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          child: const Text('Начать запись',
            style: TextStyle(
              fontFamily: 'Commissioner',
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () {
            ref.read(recorderManagerProvider).start();
          },
        ),
      ],
    );
  }
}