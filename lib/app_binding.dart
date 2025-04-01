import 'package:flutter_getx_boilerplate/api/api.dart';
import 'package:get/get.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() async {
    Get.put(ApiServices(), permanent: true);
  }
}
