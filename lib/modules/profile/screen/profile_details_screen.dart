import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/lang/generate/app_language_key.dart';
import 'package:flutter_getx_boilerplate/modules/profile/controller/profile_details_controller.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:flutter_getx_boilerplate/shared/widgets/common/cached_avatar_image.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProfileDetailsScreen extends GetView<ProfileDetailsController> {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.35),
            theme.colorScheme.onPrimary,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border.all(color: theme.colorScheme.outlineVariant, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios,
                  color: theme.colorScheme.onPrimaryContainer, size: 15.w),
              onPressed: () => Get.back(),
            ),
          ),
          title: Text(
            AppLanguageKey.profile_info.tr,
            style: TextStyle(
              color: theme.colorScheme.onSecondaryContainer,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: theme.colorScheme.outlineVariant, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(Icons.save_outlined,
                    color: theme.colorScheme.onPrimaryContainer, size: 24),
                onPressed: controller.saveProfile,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                // Work Information Card
                _buildWorkInfoCard(theme),
                // Personal Information Card
                _buildPersonalInfoCard(theme),
                // Identity Information Card
                _buildIdentityInfoCard(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkInfoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.only(
        top: kDefaultPadding,
        left: kDefaultPadding,
        right: kDefaultPadding,
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.work_outline, color: theme.colorScheme.primary),
                  const Space(width: 8),
                  Text(
                    AppLanguageKey.work_info,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Space(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: controller.pickImage,
                        child: Stack(
                          children: [
                            Obx(
                              () => Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: controller.imageURL.value.isNotEmpty
                                      ? Image.file(
                                          File(controller.imageURL.value),
                                          fit: BoxFit.cover,
                                        )
                                      : CachedAvatarImage(
                                          imageUrl:
                                              controller.user.value?.imageURL,
                                          size: 100,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Space(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNonEditableField(
                          Icons.badge,
                          AppLanguageKey.employee_no,
                          controller.user.value?.employeeNo ?? '--',
                          theme,
                        ),
                        _buildNonEditableField(
                          Icons.email,
                          AppLanguageKey.email,
                          controller.user.value?.email ?? '--',
                          theme,
                        ),
                        _buildNonEditableField(
                          Icons.work,
                          AppLanguageKey.position,
                          _getPositionName(),
                          theme,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_outline, color: theme.colorScheme.primary),
                  const Space(width: 8),
                  Text(
                    AppLanguageKey.personal_info,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Space(height: 16),
              InputFieldWidget(
                label: AppLanguageKey.full_name.tr,
                controller: controller.fullNameController,
                hint: AppLanguageKey.enter_full_name.tr,
                important: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return AppLanguageKey.required_field.tr;
                  }
                  return null;
                },
              ),
              const Space(height: 16),
              InputFieldWidget(
                label: AppLanguageKey.japanese_name.tr,
                controller: controller.japaneseNameController,
                hint: AppLanguageKey.enter_japanese_name.tr,
              ),
              const Space(height: 16),
              InputFieldWidget(
                label: AppLanguageKey.nickname.tr,
                controller: controller.nickNameController,
                hint: AppLanguageKey.enter_nickname.tr,
                important: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return AppLanguageKey.required_field.tr;
                  }
                  return null;
                },
              ),
              const Space(height: 16),
              Obx(() => InputFieldWidget(
                    label: AppLanguageKey.birthday.tr,
                    controller: TextEditingController(
                      text: DateFormat('yyyy-MM-dd')
                          .format(controller.birthday.value),
                    ),
                    hint: AppLanguageKey.select_birthday.tr,
                    onSelectDate: () => controller.selectBirthday(),
                    readOnly: true,
                    fieldType: InputFieldType.calendar,
                    important: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return AppLanguageKey.required_field.tr;
                      }
                      return null;
                    },
                  )),
              const Space(height: 16),
              Obx(
                () => DropdownButtonFormField<int>(
                  value: controller.gender.value,
                  hint: Text(AppLanguageKey.gender),
                  items: [
                    DropdownMenuItem(
                        value: 1, child: Text(AppLanguageKey.male.tr)),
                    DropdownMenuItem(
                        value: 0, child: Text(AppLanguageKey.female.tr)),
                  ],
                  onChanged: (val) => controller.gender.value = val!,
                  decoration: InputDecoration(
                    labelText: AppLanguageKey.gender.tr,
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Space(height: 16),
              Obx(
                () => DropdownButtonFormField<int>(
                  hint: Text(AppLanguageKey.marital_status),
                  value: controller.maritalStatus.value,
                  items: [
                    DropdownMenuItem(
                        value: 0, child: Text(AppLanguageKey.single.tr)),
                    DropdownMenuItem(
                        value: 1, child: Text(AppLanguageKey.married.tr)),
                  ],
                  onChanged: (val) => controller.maritalStatus.value = val!,
                  decoration: InputDecoration(
                    labelText: AppLanguageKey.marital_status.tr,
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Space(height: 16),
              InputFieldWidget(
                label: AppLanguageKey.number_of_children.tr,
                controller: TextEditingController(
                  text: controller.numberOfChildren.value.toString(),
                ),
                hint: AppLanguageKey.enter_number_of_children.tr,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  controller.numberOfChildren.value = int.tryParse(value) ?? 0;
                },
              ),
              const Space(height: 16),
              InputFieldWidget(
                label: AppLanguageKey.phone_number.tr,
                controller: controller.phoneController,
                hint: AppLanguageKey.enter_phone_number.tr,
                keyboardType: TextInputType.number,
                important: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return AppLanguageKey.required_field.tr;
                  }
                  if (value?.length != 10) {
                    return AppLanguageKey.phone_number_10_digits.tr;
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value!)) {
                    return AppLanguageKey.phone_number_only_digits.tr;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityInfoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.only(
        left: kDefaultPadding,
        right: kDefaultPadding,
        bottom: kDefaultPadding,
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.badge_outlined, color: theme.colorScheme.primary),
                  const Space(width: 8),
                  Text(
                    AppLanguageKey.id_info.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Space(height: 16),
              InputFieldWidget(
                label: AppLanguageKey.id_number.tr,
                controller: controller.idNumberController,
                hint: AppLanguageKey.enter_id_number.tr,
                keyboardType: TextInputType.number,
                important: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return AppLanguageKey.required_field.tr;
                  }
                  return null;
                },
              ),
              const Space(height: 16),
              Obx(() => InputFieldWidget(
                    label: AppLanguageKey.id_issue_date.tr,
                    controller: TextEditingController(
                      text: DateFormat('yyyy-MM-dd')
                          .format(controller.idIssueDate.value),
                    ),
                    hint: AppLanguageKey.select_id_issue_date.tr,
                    onSelectDate: () => controller.selectIdIssueDate(),
                    readOnly: true,
                    fieldType: InputFieldType.calendar,
                    important: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return AppLanguageKey.required_field.tr;
                      }
                      return null;
                    },
                  )),
              const Space(height: 16),
              InputFieldWidget(
                label: AppLanguageKey.id_issue_place.tr,
                controller: controller.idIssuePlaceController,
                hint: AppLanguageKey.enter_id_issue_place.tr,
                important: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return AppLanguageKey.required_field.tr;
                  }
                  return null;
                },
              ),
              const Space(height: 16),
              InputFieldWidget(
                label: AppLanguageKey.hometown.tr,
                controller: controller.hometownController,
                hint: AppLanguageKey.enter_hometown.tr,
                important: true,
              ),
              const Space(height: 16),
              InputFieldWidget(
                label: AppLanguageKey.permanent_address.tr,
                controller: controller.permanentAddressController,
                hint: AppLanguageKey.enter_permanent_address.tr,
                important: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return AppLanguageKey.required_field.tr;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNonEditableField(
      IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const Space(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer,
                    fontSize: 14,
                  ),
                ),
                const Space(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPositionName() {
    final currentLocale = Get.locale?.languageCode ?? 'vi';
    final position = controller.user.value?.positionResponse;

    if (position == null) return '--';

    switch (currentLocale) {
      case 'en':
        return position.nameEn ?? '--';
      case 'ja':
        return position.nameJa ?? '--';
      case 'vi':
      default:
        return position.nameVi ?? '--';
    }
  }
}
