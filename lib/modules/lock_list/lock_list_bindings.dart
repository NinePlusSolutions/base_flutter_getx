import 'package:get/get.dart';
import '../../api/ttlock_api_service.dart';
import '../../repositories/ttlock_repository.dart';
import './lock_list_controller.dart';

class LockListBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TTLockRepository>(() => TTLockRepository(
          apiService: Get.find<TTLockApiService>(),
        ));
    Get.lazyPut<LockListController>(
      () => LockListController(Get.find()),
    );
  }
}
