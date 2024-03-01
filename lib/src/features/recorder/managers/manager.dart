import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lanius/permission_manager.dart';
import 'package:lanius/src/features/recorder/entities/entity.dart';
import 'package:lanius/src/features/recorder/entities/states.dart';
import 'package:lanius/src/features/recorder/providers/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecorderManager {
  final PermissionManager _permissionManager;
  final OngoingRecordProvider _ongoingRecordProvider;
  final StateController<RecorderState> _recorderStateController;
  final AudioRecorder _audioRecorder;

  RecorderManager(
      this._permissionManager,
      this._ongoingRecordProvider,
      this._audioRecorder,
      this._recorderStateController
      );

  Future<void> start() async {
    _recorderStateController.state = RecorderState.loading;
    final permissionGranted = await _permissionManager.validatePermission();
    if (!permissionGranted){
      _recorderStateController.state = RecorderState.permissionRequired;
      return;
    }

    final savePath = await getTemporaryDirectory();

    bool appFolderExists = await savePath.exists();
    if (!appFolderExists) {
      await savePath.create(recursive: true);
    }

    final startAt = DateTime.now();
    final filePath = "${savePath.path}/${startAt.toIso8601String()}.rn";

    _ongoingRecordProvider.recordStarted(
      RecordEntity(startAt: startAt, fileName: filePath),
    );

    await _audioRecorder.start(const RecordConfig(), path: filePath);

    _recorderStateController.state = RecorderState.active;
  }

  Future<void> stop() async {
    _recorderStateController.state = RecorderState.loading;
    if (!await _audioRecorder.isRecording()) {
      _recorderStateController.state = RecorderState.inactive;
    }

    final savePath = await _audioRecorder.stop();

    if (savePath == null) {
      _ongoingRecordProvider.recordEnd();
      return;
    }

    _ongoingRecordProvider.recordEnd();

    _recorderStateController.state = RecorderState.inactive;
  }
}