import 'package:get/get.dart';
import 'package:flutter/material.dart';

void closeDialogSafely() {
  if (Get.isDialogOpen ?? false) {
    Navigator.of(Get.context!).pop();
  }
}

void showSnackbarSafely(String title, String message) {
  if (!Get.isSnackbarOpen) {
    Get.snackbar(title, message);
  }
}
