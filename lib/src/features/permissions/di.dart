import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lanius/src/features/permissions/managers/manager.dart';

final permissionManagerProvider = Provider<PermissionManager>((ref) => PermissionManager());