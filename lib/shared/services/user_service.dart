import 'package:get/get.dart';
import 'package:flutter_getx_boilerplate/models/model/user_model.dart';

class UserService extends GetxService {
  static UserService get to => Get.find();

  final _user = Rx<UserModel?>(null);
  UserModel? get user => _user.value;
  set user(UserModel? value) => _user.value = value;

  void clearUser() {
    _user.value = null;
  }

  bool get isLoggedIn => _user.value != null;
}
