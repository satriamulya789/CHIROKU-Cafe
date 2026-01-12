import 'dart:io';
import 'package:chiroku_cafe/feature/admin/admin_setting_manage_qris/models/admin_setting_manage_qris_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting_manage_qris/repositories/admin_setting_manage_qris_repositories.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting_manage_qris/widgets/admin_manage_qris_confirm_dialog.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting_manage_qris/widgets/admin_manage_qris_image_dialog.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PaymentSettingsController extends GetxController {
  final PaymentSettingsRepository _repository = PaymentSettingsRepository();
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;
  final isUploadingImage = false.obs;
  final paymentSettings = Rxn<PaymentSettingsModel>();
  final selectedImage = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    loadPaymentSettings();
  }

  Future<void> loadPaymentSettings() async {
    try {
      isLoading.value = true;
      final settings = await _repository.getPaymentSettings();
      paymentSettings.value = settings;
    } catch (e) {
      CustomSnackbar().showErrorSnackbar(
        'Failed to load payment settings: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
        await uploadQrisImage();
      }
    } catch (e) {
      CustomSnackbar().showErrorSnackbar(
        'Failed to pick image: $e',
      );
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
        await uploadQrisImage();
      }
    } catch (e) {
      CustomSnackbar().showErrorSnackbar(
        'Failed to take photo: $e',
      );
    }
  }

  Future<void> uploadQrisImage() async {
    if (selectedImage.value == null) return;

    try {
      isUploadingImage.value = true;

      final String? newQrisUrl = await _repository.uploadAndUpdateQris(
        imageFile: selectedImage.value!,
        oldQrisUrl: paymentSettings.value?.qrisUrl,
      );

      if (newQrisUrl != null) {
        paymentSettings.value = paymentSettings.value?.copyWith(
          qrisUrl: newQrisUrl,
          updatedAt: DateTime.now(),
        );

        CustomSnackbar().showSuccessSnackbar(
          'QRIS image updated successfully',
        );
      }
    } catch (e) {
      CustomSnackbar().showErrorSnackbar(
        'Failed to upload QRIS image: ${e.toString()}',
      );
    } finally {
      isUploadingImage.value = false;
      selectedImage.value = null;
    }
  }

  Future<void> removeQrisImage() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AdminSettingManageQrisConfirmDialogWidget(
          title: 'Remove QRIS',
          message: 'Are you sure you want to remove the QRIS image?',
        ),
      );

      if (confirmed == true) {
        isLoading.value = true;
        await _repository.removeQris();

        paymentSettings.value = paymentSettings.value?.copyWith(
          qrisUrl: '',
          updatedAt: DateTime.now(),
        );

        CustomSnackbar().showSuccessSnackbar(
          'QRIS image removed successfully',
        );
      }
    } catch (e) {
      CustomSnackbar().showErrorSnackbar(
        'Failed to remove QRIS image: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showImageSourceDialog() {
    Get.dialog(
      AdminSettingManageQrisImageSourceDialogWidget(
        onGalleryTap: () {
          Get.back();
          pickImageFromGallery();
        },
        onCameraTap: () {
          Get.back();
          pickImageFromCamera();
        },
      ),
    );
  }
}