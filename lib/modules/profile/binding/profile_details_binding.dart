import 'package:flutter_getx_boilerplate/modules/profile/export/profile.dart';
import 'package:flutter_getx_boilerplate/repositories/profile_repository.dart';
import 'package:get/get.dart';

class ProfileDetailsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRepository>(
          () => ProfileRepository(
        apiClient: Get.find(),
      ),
    );


    Get.lazyPut<ProfileDetailsController>(
          () => ProfileDetailsController(Get.find()),
    );
  }
}
