import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gazette/services/StorageService.dart';
import 'package:gazette/models/AnecdoteModel.dart';
import 'package:gazette/utils/Colors.dart';
import 'package:gazette/utils/Common.dart';
import 'package:get/get.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
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
  final draftStatus = RxnString();
  final actionError = RxnString();
  final submittedError = RxnString();
  final isLoadingSubmitted = false.obs;
  VoidCallback? retryAction;
  String? _imageData;
  Uint8List? _selectedImageBytes;
  Uint8List? get selectedImageBytes => _selectedImageBytes;
  String? _cleanupWarning;
  bool _restoring = false;
  bool _switching = false;
  bool _pickingImage = false;
  int _draftRevision = 0;
  String get _draftId => openedAnecdote?.id ?? 'new';
  String get _userId => _pocketbaseService.user!.id;

  Future<bool> saveDraft() async {
    if (_restoring) return true;
    final revision = ++_draftRevision;
    draftStatus.value = null;
    try {
      await StorageService.to.writeDraft(_userId, _draftId, {
        'text': contentTextController.text,
        'date': selectedDate.toIso8601String(),
        'image': _imageData,
        'imageName': selectedImage?.name,
      });
      if (revision == _draftRevision) {
        draftStatus.value = null;
      }
      return true;
    } catch (e) {
      if (revision == _draftRevision) {
        draftStatus.value =
            'Brouillon non enregistré. Gardez cette page ouverte et réessayez.';
      }
      Get.log('Draft storage error: $e');
      return false;
    }
  }

  void _onTextChanged() {
    saveDraft();
  }

  Future<void> _clearDraft() async {
    try {
      await StorageService.to.removeDraft(_userId, _draftId);
      draftStatus.value = null;
    } catch (e) {
      _cleanupWarning =
          'Envoi effectué, mais le brouillon local n’a pas pu être effacé.';
      Get.log('Draft storage error: $e');
    }
  }

  void _showActionError(String message, VoidCallback retry) {
    retryAction = retry;
    actionError.value = message;
  }

  @override
  void onInit() {
    updateForm();
    contentTextController.addListener(_onTextChanged);
    getSubmittedAnecdotes();
    afterBuildCreated(() {
      setStatusBarColor(getScaffoldColor());
    });
    super.onInit();
  }

  void pickerImage(BuildContext context) async {
    if (isUploading.value || _pickingImage || _switching) return;
    _pickingImage = true;
    actionError.value = null;
    try {
      final ImagePicker picker = ImagePicker();
      XFile? picked = await picker.pickImage(
          source: ImageSource.gallery, maxWidth: 1500, maxHeight: 1500);

      if (picked != null) {
        final decodedImage =
            await decodeImageFromList(await picked.readAsBytes());
        final aspectRatio =
            (decodedImage.height > decodedImage.width) ? 0.724 : 2.014;

        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: picked.path,
          compressQuality: 100,
          uiSettings: [
            WebUiSettings(
                context: context,
                presentStyle: WebPresentStyle.page,
                viewwMode: WebViewMode.mode_1,
                initialAspectRatio: aspectRatio,
                cropBoxResizable: false,
                movable: false,
                dragMode: WebDragMode.none)
          ],
        );

        if (croppedFile != null) {
          final image = XFile(croppedFile.path, name: picked.name);
          final bytes = await image.readAsBytes();
          final imageData = base64Encode(bytes);
          selectedImage = image;
          _selectedImageBytes = bytes;
          _imageData = imageData;
          selectedImageError = false;
          await saveDraft();
          update();
        }
      }
    } catch (e) {
      _showActionError(
          'Impossible d’ouvrir cette image. Réessayez ou choisissez une autre photo.',
          () => pickerImage(context));
      Get.log('Image selection error: $e');
    } finally {
      _pickingImage = false;
    }
  }

  Future<void> pickerDate(BuildContext context) async {
    if (isUploading.value || _switching) return;
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
      await saveDraft();
      update();
    }
  }

  void removeSelectedImage() {
    if (isUploading.value || _pickingImage || _switching) return;
    selectedImage = null;
    _selectedImageBytes = null;
    _imageData = null;
    selectedImageError = false;
    saveDraft();
    update();
  }

  String getSelectedDate() {
    return new DateFormat.yMd("fr_FR")
        .format(selectedDate)
        .capitalizeFirstLetter();
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

  Future<void> sendNewAnecdote() async {
    if (isUploading.value || _pickingImage || _switching) return;
    actionError.value = null;
    if (selectedImage == null) {
      selectedImageError = true;
      update();
    }

    if (!formKey.currentState!.validate() || selectedImage == null) {
      return;
    }

    isUploading.value = true;
    try {
      submittedAnecdotes.add(await _pocketbaseService.createAnecdote(
          contentTextController.text, selectedImage!, selectedDate));
      await _clearDraft();
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
      _showActionError(
          'Envoi impossible. Votre saisie est conservée. Vérifiez votre connexion puis réessayez.',
          sendNewAnecdote);
      Get.log('GotError : $e');
    }
  }

  Future<void> sendUpdatedAnecdote() async {
    if (isUploading.value || _pickingImage || _switching) return;
    actionError.value = null;
    if (!formKey.currentState!.validate()) {
      return;
    }

    isUploading.value = true;
    try {
      Anecdote updatedAnecdote = await _pocketbaseService.updateAnecdote(
          openedAnecdote!,
          contentTextController.text,
          selectedImage,
          selectedDate);
      await _clearDraft();
      submittedAnecdotes
          .removeWhere((anecdote) => anecdote.id == openedAnecdote!.id);
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
      _showActionError(
          'Modification impossible. Votre saisie est conservée. Vérifiez votre connexion puis réessayez.',
          sendUpdatedAnecdote);
      Get.log('GotError : $e');
    }
  }

  Future<void> deleteAnecdote() async {
    if (isUploading.value) return;
    actionError.value = null;
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
            await _clearDraft();
            submittedAnecdotes
                .removeWhere((anecdote) => anecdote.id == openedAnecdote!.id);
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
            _showActionError(
                'Suppression impossible. L’anecdote est conservée.',
                deleteAnecdote);
            Get.log('GotError : $e');
          }
        });
  }

  Future<void> getSubmittedAnecdotes() async {
    if (isLoadingSubmitted.value) return;
    isLoadingSubmitted.value = true;
    submittedError.value = null;
    try {
      submittedAnecdotes =
          await _pocketbaseService.getAllSubmittedAnecdotesFromCurrentUser();
      update();
    } catch (e) {
      submittedError.value = 'Impossible de charger vos anecdotes envoyées.';
      Get.log('GotError : $e');
    } finally {
      isLoadingSubmitted.value = false;
    }
  }

  String getUserName() {
    return _pocketbaseService.user?.firstname ?? "";
  }

  void updateForm() {
    _restoring = true;
    _draftRevision++;
    contentTextController.text = openedAnecdote?.text ?? "";
    selectedImage = null;
    _selectedImageBytes = null;
    _imageData = null;
    selectedImageError = false;
    selectedDate = openedAnecdote?.date ?? new DateTime.now();
    actionError.value = null;
    try {
      final draft = StorageService.to.readDraft(_userId, _draftId);
      if (draft != null) {
        contentTextController.text = draft['text'] as String? ?? '';
        selectedDate =
            DateTime.tryParse(draft['date'] as String? ?? '') ?? selectedDate;
        _imageData = draft['image'] as String?;
        if (_imageData != null) {
          _selectedImageBytes = base64Decode(_imageData!);
          selectedImage = XFile.fromData(_selectedImageBytes!,
              name: draft['imageName'] as String? ?? 'photo.jpg');
        }
        draftStatus.value = 'Brouillon restauré depuis cet appareil';
      } else {
        draftStatus.value = null;
      }
    } catch (e) {
      draftStatus.value =
          'Impossible de restaurer le brouillon sur cet appareil.';
      Get.log('Draft restore error: $e');
    } finally {
      _restoring = false;
    }
    if (_cleanupWarning != null) {
      draftStatus.value = _cleanupWarning;
      _cleanupWarning = null;
    }
    update();
  }

  Future<void> openAnecdote(int index) async {
    if (isUploading.value || _pickingImage || _switching) return;
    final target = index < 0 ? null : submittedAnecdotes[index];
    if (target?.id == openedAnecdote?.id) return;
    _switching = true;
    try {
      if (!await saveDraft()) {
        final discard = await Get.dialog<bool>(AlertDialog(
          title: const Text('Brouillon non enregistré'),
          content: const Text(
              'Le brouillon n’a pas pu être enregistré. Changer d’anecdote effacera votre saisie actuelle.'),
          actions: [
            TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Rester')),
            TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Abandonner les modifications')),
          ],
        ));
        if (discard != true) return;
      }
      openedAnecdote = target;
      updateForm();
    } finally {
      _switching = false;
    }
  }

  bool isAnecdoteOpened(int index) {
    return openedAnecdote?.id == submittedAnecdotes[index].id;
  }

  @override
  void onClose() {
    contentTextController.removeListener(_onTextChanged);
    contentTextController.dispose();
    super.onClose();
  }
}
