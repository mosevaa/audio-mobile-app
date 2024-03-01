import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  bool? _permissionGranted;

  Future<bool> validatePermissions() async {
    final permissionGranted = _permissionGranted;
    if (permissionGranted != null) return permissionGranted;

    final permissions = await [
      Permission.manageExternalStorage,
      Permission.microphone
    ].request();

    _permissionGranted = permissions.values.every((element) => element.isGranted);

    if (_permissionGranted == false && permissions.values.any((element) => element.isDenied || element.isPermanentlyDenied)) {
      openAppSettings();
    }

    return _permissionGranted ?? false;
  }
}