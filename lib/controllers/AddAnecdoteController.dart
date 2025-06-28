import 'package:flutter/material.dart';
import 'package:gazette/models/AnecdoteModel.dart';
import 'package:gazette/utils/Colors.dart';
import 'package:gazette/utils/Common.dart';
import 'package:get/get.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';

class AddAnecdoteController extends GetxController {
  XFile? selectedImage;
  DateTime selectedDate = DateTime.now();
  final contentTextController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxBool isUploading = false.obs;
  bool selectedImageError = false;
  List<Anecdote> submittedAnecdotes = [];
  final _pocketbaseService = PocketbaseService.to;
  Anecdote? openedAnecdote = null;

  @override
  void onInit() {
    getSubmittedAnecdotes();
    afterBuildCreated(() {
      setStatusBarColor(getScaffoldColor());
    });
    super.onInit();
  }

  void pickerImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1500, maxHeight: 1500);
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
    return new DateFormat.yMd("fr_FR").format(selectedDate).capitalizeFirstLetter();
  }

  String getSelectedImageName() {
    if (openedAnecdote == null) {
      return selectedImage?.name ?? "Aucune image sélectionné";
    } else {
      return selectedImage?.name ?? openedAnecdote!.imageFileName;
    }
  }

  Color? getSelectedImageNameColor() {
    return selectedImageError ? Colors.red : null;
  }

  void sendNewAnecdote() async {
    if (selectedImage == null) {
      selectedImageError = true;
      update();
    }

    if (!formKey.currentState!.validate() || selectedImage == null) {
      return;
    }

    isUploading.value = true;
    try {
      submittedAnecdotes.add(await _pocketbaseService.createAnecdote(contentTextController.text, selectedImage!, selectedDate));
      openedAnecdote = submittedAnecdotes.last;
      updateForm();
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

  void sendUpdatedAnecdote() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isUploading.value = true;
    try {
      Anecdote updatedAnecdote = await _pocketbaseService.updateAnecdote(openedAnecdote!, contentTextController.text, selectedImage, selectedDate);
      submittedAnecdotes.remove(openedAnecdote);
      submittedAnecdotes.add(updatedAnecdote);
      openedAnecdote = updatedAnecdote;
      updateForm();
      Get.showSnackbar(
        GetSnackBar(
          title: "Anecdote corrigée",
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

  Future<void> deleteAnecdote() async {
    Get.defaultDialog(
        middleText: "Est-tu sûr de vouloir supprimer cette anecdote ?",
        title: "Confirmation",
        textConfirm: "Supprimer",
        textCancel: "Annuler",
        buttonColor: AppColorPrimary,
        cancelTextColor: AppColorPrimary,
        radius: 5,
        onCancel: () {},
        onConfirm: () async {
          Get.close(1);
          isUploading.value = true;
          try {
            await PocketbaseService.to.deleteAnecdote(openedAnecdote!);
            submittedAnecdotes.remove(openedAnecdote);
            openedAnecdote = null;
            updateForm();
            Get.showSnackbar(
              GetSnackBar(
                title: "Anecdote supprimée",
                message: "Elle ne sera pas publiée",
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
        });
  }

  Future<void> getSubmittedAnecdotes() async {
    try {
      submittedAnecdotes = await _pocketbaseService.getAllSubmittedAnecdotesFromCurrentUser();
      update();
    } catch (e) {
      Get.log('GotError : $e');
    }
  }

  String getUserName() {
    return _pocketbaseService.user?.firstname ?? "";
  }

  void updateForm() {
    contentTextController.text = openedAnecdote?.text ?? "";
    selectedImage = null;
    selectedImageError = false;
    selectedDate = openedAnecdote?.date ?? new DateTime.now();
    update();
  }

  void openAnecdote(int index) {
    if (index < 0) {
      // New anecdote selected
      if (openedAnecdote != null) {
        openedAnecdote = null;
        updateForm();
      }
    } else {
      if (openedAnecdote != submittedAnecdotes[index]) {
        openedAnecdote = submittedAnecdotes[index];
        updateForm();
      }
    }
  }

  bool isAnecdoteOpened(int index) {
    return openedAnecdote == submittedAnecdotes[index];
  }
}
