import 'package:get/get.dart';
import '../../repositories/ttlock_repository.dart';
import './gateway_detail_controller.dart';

class GatewayDetailBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GatewayDetailController>(() => GatewayDetailController(
          Get.find<TTLockRepository>(),
          int.parse(Get.parameters['id'] ?? '0'),
        ));
  }
}
