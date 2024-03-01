import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lanius/providers.dart';
import 'package:lanius/src/features/recorder/entities/states.dart';
import 'package:lanius/src/features/recorder/managers/manager.dart';
import 'package:lanius/src/features/recorder/providers/provider.dart';
import 'package:record/record.dart';

final recorderState = StateProvider((ref) => RecorderState.inactive);

final ongoingRecordProviderProvider = Provider<OngoingRecordProvider>((ref) {
  final instance = OngoingRecordProvider();
  ref.onDispose(instance.dispose);
  instance.init();
  return instance;
});

final recorderManagerProvider = Provider<RecorderManager>((ref) => RecorderManager(
  ref.read(permissionManagerProvider),
  ref.read(ongoingRecordProviderProvider),
  AudioRecorder(),
  ref.read(recorderState.notifier),
  ),
);