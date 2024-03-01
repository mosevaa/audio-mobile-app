import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lanius/providers.dart';

class NeedPermissions extends ConsumerWidget {
  const NeedPermissions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Для работы приложения необходимы разрешения',
          style: TextStyle(
            fontFamily: 'Commissioner',
          ),
        ),
        TextButton(
          child: const Text('Предоставить разрешения'),
          onPressed: () {
            ref.read(permissionManagerProvider).validatePermission();
          }
        ),
      ],
    );
  }
}