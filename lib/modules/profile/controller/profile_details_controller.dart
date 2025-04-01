import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/lang/generate/app_language_key.dart';
import 'package:flutter_getx_boilerplate/models/model/user_model.dart';
import 'package:flutter_getx_boilerplate/models/request/identity_request.dart';
import 'package:flutter_getx_boilerplate/modules/base/base_controller.dart';
import 'package:flutter_getx_boilerplate/repositories/profile_repository.dart';
import 'package:flutter_getx_boilerplate/shared/services/user_service.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileDetailsController extends BaseController<ProfileRepository> {
  var imageURL = ''.obs;
  var birthday = DateTime.now().obs;
  Rx<int?> gender = Rx<int?>(null);
  Rx<int?> maritalStatus = Rx<int?>(null); // 0: Single, 1: Married
  var numberOfChildren = 0.obs;

  // Form controllers
  final fullNameController = TextEditingController();
  final japaneseNameController = TextEditingController();
  final nickNameController = TextEditingController();
  final phoneController = TextEditingController();
  final idNumberController = TextEditingController();
  final idIssuePlaceController = TextEditingController();
  final hometownController = TextEditingController();
  final permanentAddressController = TextEditingController();

  // Date values
  var idIssueDate = DateTime.now().obs;

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Add reactive user variable
  final user = Rx<UserModel?>(null);

  ProfileDetailsController(super.repository);

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  void getProfile() {
    user.value = UserService.to.user;
    if (user.value != null) {
      // Populate form fields with user data
      fullNameController.text = user.value?.fullName ?? '';
      japaneseNameController.text = user.value?.katakanaName ?? '';
      nickNameController.text = user.value?.nickName ?? '';
      phoneController.text = user.value?.phoneNo ?? '';
      idIssuePlaceController.text = '';
      hometownController.text = user.value?.placeOfBirth ?? '';
      permanentAddressController.text = user.value?.address ?? '';

      // Set observable values
      birthday.value = user.value?.birthday ?? DateTime.now();
      gender.value = user.value?.gender;
      maritalStatus.value = user.value?.maritalStatus;
      numberOfChildren.value = user.value?.numberChild ?? 0;
      idIssueDate.value = DateTime.now();
      imageURL.value = user.value?.imageURL ?? '';
    }
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(AppLanguageKey.take_photo.tr),
              onTap: () async {
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  imageURL.value = pickedFile.path;
                }
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: Text(AppLanguageKey.choose_from_gallery.tr),
              onTap: () async {
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  imageURL.value = pickedFile.path;
                }
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close_outlined),
              title: Text(AppLanguageKey.cancel.tr),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  void selectBirthday() async {
    DateTime? pickedDate = await Get.dialog(
      DatePickerDialog(
        initialDate: birthday.value,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      ),
    );
    if (pickedDate != null) {
      birthday.value = pickedDate;
    }
  }

  void selectIdIssueDate() async {
    DateTime? pickedDate = await Get.dialog(
      DatePickerDialog(
        initialDate: idIssueDate.value,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      ),
    );

    if (pickedDate != null) {
      idIssueDate.value = pickedDate;
    }
  }

  bool validateForm() {
    if (!formKey.currentState!.validate()) return false;

    // Additional validation if needed
    if (birthday.value.isAfter(DateTime.now())) {
      Get.snackbar('Error', 'Invalid birthday date');
      return false;
    }

    return true;
  }

  Future<void> saveProfile() async {
    if (!validateForm()) return;

    try {
      final identityRequest = IdentityRequest(
        identityCard: idNumberController.text,
        provideDateIdentityCard: idIssueDate.value,
        providePlaceIdentityCard: idIssuePlaceController.text,
      );

      final identityResponse = await repository.updateIdentity(identityRequest);
      if (!identityResponse.succeeded) {
        showError(AppLanguageKey.common_error,
            identityResponse.messages?[0].messageText ?? '');
        return;
      }

      // Update user information
      final updatedUser = user.value?.copyWith(
        fullName: fullNameController.text,
        katakanaName: japaneseNameController.text,
        nickName: nickNameController.text,
        birthday: birthday.value,
        gender: gender.value,
        maritalStatus: maritalStatus.value,
        numberChild: numberOfChildren.value,
        phoneNo: phoneController.text,
        placeOfBirth: hometownController.text,
        address: permanentAddressController.text,
      );

      if (updatedUser == null) {
        showError(AppLanguageKey.edit_failed, AppLanguageKey.edit_failed_desc);
        return;
      }

      final infoResponse = await repository.updateProfile(updatedUser);
      if (!infoResponse.succeeded) {
        showError(
            AppLanguageKey.edit_failed,
            identityResponse.messages?[0].messageText ??
                AppLanguageKey.edit_failed_desc);
        return;
      }

      // Update local user data
      UserService.to.user = updatedUser;

      showSuccess(
        AppLanguageKey.edit_success,
        AppLanguageKey.edit_success_desc,
      );

      Get.back();
    } catch (e) {
      showError(AppLanguageKey.edit_failed, AppLanguageKey.edit_failed_desc);
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    japaneseNameController.dispose();
    nickNameController.dispose();
    phoneController.dispose();
    idNumberController.dispose();
    idIssuePlaceController.dispose();
    hometownController.dispose();
    permanentAddressController.dispose();
    super.onClose();
  }
}
