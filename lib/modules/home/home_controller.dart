import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/base/base_controller.dart';
import 'package:flutter_getx_boilerplate/models/response/error/error_response.dart';
import 'package:flutter_getx_boilerplate/models/response/user/user.dart';
import 'package:flutter_getx_boilerplate/repositories/auth_repository.dart';
import 'package:get/get.dart';

class HomeController extends BaseController<AuthRepository> {
  HomeController(super.repository);
  final user = Rx<User?>(null as User?);

  final searchController = TextEditingController();

  @override
  Future getData() async {
    try {
      final res = await repository.me();
      user.value = res;
    } on ErrorResponse catch (e) {
      showError("", e.message);
    } catch (e) {
      showError("", e.toString());
    }
  }
}
