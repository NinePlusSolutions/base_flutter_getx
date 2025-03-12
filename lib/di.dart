import 'package:flutter_getx_boilerplate/shared/services/download_services.dart';
import 'package:get/get.dart';

import 'shared/services/services.dart';

class DependencyInjection {
  static Future<void> init() async {
    await Get.putAsync(() => StorageService.init());
    Get.put(() => DownloadServices());
    // Get.put(() => NotificationHandler()); // Uncomment this line if you have NotificationHandler class
  }
}
