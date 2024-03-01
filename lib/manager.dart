import 'dart:async';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lanius/api.dart';
import 'package:lanius/permission_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';

const _tickerDelay = Duration(milliseconds: 500);
final _triggerOffsetDuration = const Duration(seconds: 5) + _tickerDelay;
const _silenceRestartDuration = Duration(minutes: 5);

const _ampTrashHold = -20;

enum RecordStatus {
  permissionRequired,
  inactive,
  active,
}

class RecordManager {
  final StateController<RecordStatus> _statusController;
  final PermissionManager _permissionManager;
  final MyAPI _api;

  final AudioRecorder _audioRecorder = AudioRecorder();

  RecordManager(
      this._statusController,
      this._permissionManager,
      this._api,
      );

  late final Directory _recDic;

  DateTime? startTime;
  Timer? _ampTimer;
  DateTime? _triggered;
  DateTime? _leastTriggered;
  int recId = 0;
  File? _recFile;
  Completer<void>? _trimmerCompleter;

  void init() async {
    _recDic = await getTemporaryDirectory();
    bool appFolderExists = await _recDic.exists();
    if (!appFolderExists) {
      await _recDic.create(recursive: true);
    }

    _permissionManager.validatePermission();
  }

  Future<void> start() async {
    if (!await _permissionManager.validatePermission()) {
      _statusController.state = RecordStatus.permissionRequired;
      return;
    }

    await _restartRec();
    _ampTimer = Timer.periodic(_tickerDelay, (_) => _onTick());
    _statusController.state = RecordStatus.active;

  }

  Future<void> _onTick() async {
    try{
      if (startTime == null) {
        return;
      }
      final amp = await _audioRecorder.getAmplitude();
      final now = DateTime.now();
      if (amp.current > _ampTrashHold) {
        _triggered ??= now.difference(startTime!) > _triggerOffsetDuration
            ? now.subtract(_triggerOffsetDuration)
            : startTime;
        _leastTriggered = now;

        return;
      }

      if (_triggered != null) {
        if (now.difference(_leastTriggered!) > _triggerOffsetDuration) {
          _audioRecorder.stop();
          final recFile = _recFile;
          final startSec =
              _triggered!.difference(startTime!).inMilliseconds / 1000;
          final endSec = now.difference(startTime!).inMilliseconds / 1000;
          await _restartRec();
          _postRec(recFile!, startSec, endSec);
        }

        return;
      }

      if (now.difference(startTime!) > _silenceRestartDuration) {
        _audioRecorder.stop();
        _recFile?.delete();
        _restartRec();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _restartRec() async {
    recId++;
    final filepath = '${_recDic.path}/${recId}.rn';
    _recFile = File(filepath);
    startTime = DateTime.now();
    _leastTriggered = null;
    _triggered = null;
    await _audioRecorder.start(const RecordConfig(), path: filepath);
  }

  Future<void> _postRec(File recFile, double startSec, double endSec) async {
    await _trimmerCompleter?.future;
    _trimmerCompleter = Completer();
    try {
      _api.sendFile(recFile);
    } catch (e) {
      print(e);
    }

    _trimmerCompleter?.complete();
    _trimmerCompleter = null;
  }

  Future<void> getPermission() async {
    if (await _permissionManager.validatePermission()) {
      _statusController.state = RecordStatus.inactive;
    }
  }

  Future<void> stop() async {
    String? path = await _audioRecorder.stop();
    _statusController.state = RecordStatus.inactive;
    _ampTimer?.cancel();
    _ampTimer = null;
  }

  void dispose() {}
}