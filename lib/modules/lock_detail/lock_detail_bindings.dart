import 'package:get/get.dart';
import '../../api/ttlock_api_service.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/ttlock_repository.dart';
import 'lock_detail_controller.dart';

class LockDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(
        apiClient: Get.find(),
      ),
    );

    final TTLockApiService apiService = Get.find<TTLockApiService>();

    // Create and register the TTLockRepository
    Get.lazyPut<TTLockRepository>(() => TTLockRepository(apiService: apiService));
    Get.lazyPut<LockDetailController>(
      () => LockDetailController(
        Get.find(),
      ),
    );
  }
}
