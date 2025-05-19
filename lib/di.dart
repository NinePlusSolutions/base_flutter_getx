import 'package:flutter_getx_boilerplate/shared/services/download_services.dart';
import 'package:get/get.dart';

import 'api/ttlock_api_service.dart';
import 'repositories/auth_repository.dart';
import 'repositories/ttlock_repository.dart';
import 'shared/services/services.dart';

class DependencyInjection {
  static Future<void> init() async {
    await Get.putAsync(() => StorageService.init());
    Get.put(() => DownloadServices());
    // Get.put(() => NotificationHandler()); // Uncomment this line if you have NotificationHandler class
    Get.lazyPut<TTLockApiService>(
        () => TTLockApiService(
              clientId: '1bd4d8e835334c6d87b405df1e0fb7b7',
              clientSecret: '9fcf16d64dc452760f7fc1937e1654e0',
            ),
        fenix: true);

    // Repositories
    Get.lazyPut<AuthRepository>(() => AuthRepository(apiClient: Get.find()), fenix: true);
    Get.lazyPut<TTLockRepository>(() => TTLockRepository(apiService: Get.find()), fenix: true);
  }
}
