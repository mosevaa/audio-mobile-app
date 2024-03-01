import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lanius/api.dart';
import 'package:lanius/manager.dart';
import 'package:lanius/permission_manager.dart';

final recStatusProvider = StateProvider<RecordStatus>((_) => RecordStatus.inactive);

final permissionManagerProvider = Provider((_) => PermissionManager());

final apiProvider = Provider((_) => MyAPI());

final recManagerProvider = Provider((ref) {
        final res = RecordManager(
                ref.watch(recStatusProvider.notifier),
                ref.watch(permissionManagerProvider),
                ref.watch(apiProvider),
        );
        ref.onDispose(res.dispose);
        res.init();
        return res;
}
);