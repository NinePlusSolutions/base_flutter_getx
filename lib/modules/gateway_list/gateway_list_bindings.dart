import 'package:get/get.dart';
import './gateway_list_controller.dart';

class GatewayListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GatewayListController>(
      () => GatewayListController(
        Get.find(),
      ),
    );
  }
}
