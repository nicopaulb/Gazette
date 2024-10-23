import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:get/get.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';

class AddAnecdoteController extends GetxController {
  XFile? selectedImage;
  DateTime selectedDate = DateTime.now();
  final contentTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  RxBool isUploading = false.obs;
  bool selectedImageError = false;

  @override
  void onInit() {
    afterBuildCreated(() {
      setStatusBarColor(svGetScaffoldColor());
    });
    super.onInit();
  }

  void pickerImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && picked != selectedImage) {
      selectedImage = picked;
      selectedImageError = false;
      update();
    }
  }

  Future<void> pickerDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        helpText: 'Sélectionnez une date',
        cancelText: 'Annuler',
        confirmText: "Confirmer",
        fieldLabelText: 'Date',
        fieldHintText: 'Jour/Mois/Année',
        errorFormatText: 'Saisissez une date valide',
        errorInvalidText: 'Saisissez une date valide',
        context: context,
        locale: Locale('fr'),
        initialDate: selectedDate,
        firstDate: DateTime(2022),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      update();
    }
  }

  String getSelectedDate() {
    return new DateFormat.yMd("fr_FR")
        .format(selectedDate)
        .capitalizeFirstLetter();
  }

  String getSelectedImageName() {
    return selectedImage?.name ?? "Aucune image sélectionné";
  }

  Color? getSelectedImageNameColor() {
    return selectedImageError ? Colors.red : null;
  }

  void sendAnecdote(BuildContext context) async {
    if (selectedImage == null) {
      selectedImageError = true;
      update();
    }

    if (!formKey.currentState!.validate() || selectedImage == null) {
      return;
    }

    isUploading.value = true;
    try {
      await PocketbaseService.to.createAnecdote(
          contentTextController.text, selectedImage!, selectedDate);
      resetForm();
      Get.showSnackbar(
        GetSnackBar(
          title: "Anecdote transmise",
          message: 'Elle sera disponible dans la prochaine gazette !',
          backgroundColor: Color.fromARGB(255, 7, 104, 3),
          icon: const Icon(Icons.done, color: Color(0xFFFFFFFF)),
          duration: const Duration(seconds: 10),
          onTap: (snack) => Get.back(closeOverlays: true),
        ),
      );
      isUploading.value = false;
    } catch (e) {
      isUploading.value = false;
      Get.log('GotError : $e');
    }
  }

  void resetForm() {
    contentTextController.text = "";
    selectedImage = null;
    selectedImageError = false;
    selectedDate = DateTime.now();
  }
}
