import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:gazette/utils/Colors.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:gazette/models/AnecdoteModel.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:html' as html;

class AdminController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<Anecdote> anecdotes = <Anecdote>[].obs;
  int _selectedIndex = -1;
  final _clipboard = SystemClipboard.instance;
  ByteData? fontAsset;

  @override
  void onInit() {
    afterBuildCreated(() {
      setStatusBarColor(Colors.transparent);
    });
    loadAnecdotes();
    super.onInit();
  }

  Future<void> loadAnecdotes() async {
    isLoading.value = true;
    try {
      anecdotes.value = await PocketbaseService.to.getAllSubmittedAnecdotes();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.log('GotError : $e');
    }
  }

  Future<void> publish() async {
    Get.defaultDialog(
        middleText: "Est-tu sûr de vouloir publier toutes les anecdotes en attente ?",
        title: "Confirmation",
        textConfirm: "Publier",
        textCancel: "Annuler",
        buttonColor: AppColorPrimary,
        cancelTextColor: AppColorPrimary,
        radius: 5,
        onCancel: () {},
        onConfirm: () {
          isLoading.value = true;
          Future.wait(anecdotes.map((final anecdote) async {
            PocketbaseService.to.publishAnecdote(anecdote);
          }));
          anecdotes.value = [];
          isLoading.value = false;
        });
  }

  void _drawTextString(PdfPage page, String s, double fontSize, {PdfPen? pen, PdfBrush? brush, Rect? bounds, PdfStringFormat? format}) {
    Size textSize = Size(0, 0);
    do {
      fontSize--;
      textSize = PdfTrueTypeFont(fontAsset!.buffer.asUint8List(), fontSize).measureString(s, layoutArea: bounds!.size, format: format);
    } while (textSize.height > bounds.height || textSize.width > bounds.width);
    page.graphics.drawString(s, PdfTrueTypeFont(fontAsset!.buffer.asUint8List(), fontSize), pen: pen, brush: brush, bounds: bounds, format: format);
  }

  Future<void> _drawAnecdotePortraitTop(PdfPage page, double sectionWidth, double sectionHeight, double borderSize, double avatarSize,
      double textFontSize, Anecdote anecdote, Uint8List image) async {
    final PdfColor darkOrangeColor = PdfColor(147, 100, 66);
    final double sectionInnerWidth = sectionWidth - borderSize;
    final double sectionInnerHeight = sectionHeight - borderSize;

    page.graphics.drawRectangle(bounds: Rect.fromLTWH(0, 0, sectionWidth, sectionHeight), pen: PdfPen(darkOrangeColor, width: borderSize));
    try {
      page.graphics.drawImage(PdfBitmap(image), Rect.fromLTWH(borderSize / 2, borderSize / 2, sectionInnerWidth / 2, sectionInnerHeight));
    } catch (error) {
      printError(info: "Invalid image");
    }

    PdfGraphicsState saveBeforeTransform = page.graphics.save();
    page.graphics.translateTransform(sectionWidth / 2, borderSize / 2);
    await _drawAnecdotePortraitContent(page, avatarSize, sectionInnerWidth, sectionInnerHeight, textFontSize, anecdote);
    page.graphics.restore(saveBeforeTransform);
  }

  Future<void> _drawAnecdotePortraitBottom(PdfPage page, double sectionWidth, double sectionHeight, double borderSize, double avatarSize,
      double textFontSize, double sectionSpacing, Anecdote anecdote, Uint8List image) async {
    final PdfColor darkOrangeColor = PdfColor(147, 100, 66);
    final double sectionInnerWidth = sectionWidth - borderSize;
    final double sectionInnerHeight = sectionHeight - borderSize;

    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, sectionHeight + sectionSpacing, sectionWidth, sectionHeight), pen: PdfPen(darkOrangeColor, width: borderSize));
    try {
      page.graphics.drawImage(PdfBitmap(image),
          Rect.fromLTWH(sectionWidth / 2, sectionHeight + sectionSpacing + borderSize / 2, sectionInnerWidth / 2, sectionInnerHeight));
    } catch (error) {
      printError(info: "Invalid image");
    }

    PdfGraphicsState saveBeforeTransform = page.graphics.save();
    page.graphics.translateTransform(borderSize / 2, sectionHeight + sectionSpacing + borderSize / 2);
    await _drawAnecdotePortraitContent(page, avatarSize, sectionInnerWidth, sectionInnerHeight, textFontSize, anecdote);
    page.graphics.restore(saveBeforeTransform);
  }

  Future<void> _drawAnecdotePortraitContent(
    PdfPage page,
    double avatarSize,
    double sectionInnerWidth,
    double sectionInnerHeight,
    double textFontSize,
    Anecdote anecdote,
  ) async {
    final columnWidth = sectionInnerWidth / 2;
    final PdfColor darkOrangeColor = PdfColor(147, 100, 66);
    var avatarRsp = await http.get(Uri.parse(anecdote.user?.avatarUri ?? ""));

    PdfGraphicsState saveBeforeAvatar = page.graphics.save();
    page.graphics.setClip(path: PdfPath()..addEllipse(Rect.fromLTWH((sectionInnerWidth / 2 - avatarSize) / 2, 15, avatarSize, avatarSize)));
    page.graphics.drawImage(
      PdfBitmap(avatarRsp.bodyBytes),
      Rect.fromLTWH((sectionInnerWidth / 2 - avatarSize) / 2, 15, avatarSize, avatarSize),
    );

    page.graphics.restore(saveBeforeAvatar);
    page.graphics.drawString('${anecdote.user?.firstname} ${anecdote.user?.lastname}', PdfTrueTypeFont(fontAsset!.buffer.asUint8List(), 12),
        brush: PdfSolidBrush(darkOrangeColor),
        format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
        bounds: Rect.fromLTWH(0, 15 + avatarSize + 12, columnWidth, 0));
    page.graphics.drawString('le ${new DateFormat.MMMMd("fr_FR").format(anecdote.date!)}',
        PdfTrueTypeFont(fontAsset!.buffer.asUint8List(), 12, style: PdfFontStyle.italic),
        brush: PdfSolidBrush(darkOrangeColor),
        format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
        bounds: Rect.fromLTWH(0, 15 + avatarSize + 12 + 16, columnWidth, 0));
    _drawTextString(page, anecdote.text, textFontSize,
        brush: PdfSolidBrush(darkOrangeColor),
        format: PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.top),
        bounds: Rect.fromLTWH(15, 15 + avatarSize + 12 + 16 + 35, columnWidth - 30, sectionInnerHeight - (15 + avatarSize + 12 + 16 + 35)));
  }

  Future<void> _drawAnecdoteLandscapeTop(PdfPage page, double sectionWidth, double sectionHeight, double borderSize, double avatarSize,
      double textFontSize, Anecdote anecdote, Uint8List image) async {
    final PdfColor darkOrangeColor = PdfColor(147, 100, 66);
    final double sectionInnerWidth = sectionWidth - borderSize;
    final double sectionInnerHeight = sectionHeight - borderSize;
    var rspImage = await http.get(Uri.parse(anecdote.imageUri ?? ""));
    final double imageHeightFactor = 0.72;

    page.graphics.drawRectangle(bounds: Rect.fromLTWH(0, 0, sectionWidth, sectionHeight), pen: PdfPen(darkOrangeColor, width: borderSize));
    try {
      page.graphics.drawImage(
          PdfBitmap(rspImage.bodyBytes), Rect.fromLTWH(borderSize / 2, borderSize / 2, sectionInnerWidth, sectionInnerHeight * imageHeightFactor));
    } catch (error) {
      printError(info: "Invalid image");
    }

    PdfGraphicsState saveBeforeTransform = page.graphics.save();
    page.graphics.translateTransform(borderSize / 2, sectionHeight * imageHeightFactor);
    await _drawAnecdoteLandscapeContent(page, avatarSize, sectionInnerWidth, sectionInnerHeight, imageHeightFactor, textFontSize, anecdote);
    page.graphics.restore(saveBeforeTransform);
  }

  Future<void> _drawAnecdoteLandscapeBottom(PdfPage page, double sectionWidth, double sectionHeight, double borderSize, double avatarSize,
      double textFontSize, double sectionSpacing, Anecdote anecdote, Uint8List image) async {
    final PdfColor darkOrangeColor = PdfColor(147, 100, 66);
    final double sectionInnerWidth = sectionWidth - borderSize;
    final double sectionInnerHeight = sectionHeight - borderSize;
    final double imageHeightFactor = 0.72;

    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, sectionHeight + sectionSpacing, sectionWidth, sectionHeight), pen: PdfPen(darkOrangeColor, width: borderSize));
    try {
      page.graphics.drawImage(PdfBitmap(image),
          Rect.fromLTWH(borderSize / 2, sectionHeight + sectionSpacing + borderSize / 2, sectionInnerWidth, sectionInnerHeight * imageHeightFactor));
    } catch (error) {
      printError(info: "Invalid image");
    }

    PdfGraphicsState saveBeforeTransform = page.graphics.save();
    page.graphics.translateTransform(borderSize / 2, sectionHeight + sectionSpacing + borderSize / 2 + sectionHeight * imageHeightFactor);
    await _drawAnecdoteLandscapeContent(page, avatarSize, sectionInnerWidth, sectionInnerHeight, imageHeightFactor, textFontSize, anecdote);
    page.graphics.restore(saveBeforeTransform);
  }

  Future<void> _drawAnecdoteLandscapeContent(
    PdfPage page,
    double avatarSize,
    double sectionInnerWidth,
    double sectionInnerHeight,
    double imageHeightFactor,
    double textFontSize,
    Anecdote anecdote,
  ) async {
    final PdfColor darkOrangeColor = PdfColor(147, 100, 66);
    var avatarRsp = await http.get(Uri.parse(anecdote.user?.avatarUri ?? ""));
    final double avatarWidthFactor = 0.25;
    final double textLayoutAreaWidth = sectionInnerWidth * (1 - avatarWidthFactor) - 5;
    final double textLayoutAreaHeight = (1 - imageHeightFactor) * sectionInnerHeight;

    PdfGraphicsState saveBeforeAvatar = page.graphics.save();
    page.graphics
        .setClip(path: PdfPath()..addEllipse(Rect.fromLTWH((sectionInnerWidth * avatarWidthFactor - avatarSize) / 2, 6, avatarSize, avatarSize)));
    page.graphics.drawImage(
      PdfBitmap(avatarRsp.bodyBytes),
      Rect.fromLTWH((sectionInnerWidth * avatarWidthFactor - avatarSize) / 2, 6, avatarSize, avatarSize),
    );
    page.graphics.restore(saveBeforeAvatar);
    page.graphics.drawString('${anecdote.user?.firstname} ${anecdote.user?.lastname}', PdfTrueTypeFont(fontAsset!.buffer.asUint8List(), 12),
        brush: PdfSolidBrush(darkOrangeColor),
        format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
        bounds: Rect.fromLTWH(0, avatarSize + 12 + 4, sectionInnerWidth * avatarWidthFactor, 0));
    page.graphics.drawString('le ${new DateFormat.MMMMd("fr_FR").format(anecdote.date!)}',
        PdfTrueTypeFont(fontAsset!.buffer.asUint8List(), 12, style: PdfFontStyle.italic),
        brush: PdfSolidBrush(darkOrangeColor),
        format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
        bounds: Rect.fromLTWH(0, avatarSize + 12 + 20, sectionInnerWidth * avatarWidthFactor, 0));
    _drawTextString(page, anecdote.text, textFontSize,
        brush: PdfSolidBrush(darkOrangeColor),
        format: PdfStringFormat(alignment: PdfTextAlignment.left, lineAlignment: PdfVerticalAlignment.middle),
        bounds: Rect.fromLTWH(sectionInnerWidth * avatarWidthFactor, 0, textLayoutAreaWidth, textLayoutAreaHeight));
  }

  void _drawPageNumber(PdfPage page, double circleSize, double bodyHeight, int pageNumber) {
    final Size pageSize = page.getClientSize();
    final PdfColor lightOrangeColor = PdfColor(217, 105, 77);
    page.graphics.drawEllipse(
      Rect.fromLTWH(pageSize.width / 2 - circleSize / 2, bodyHeight + circleSize / 2, circleSize, circleSize),
      brush: PdfSolidBrush(lightOrangeColor),
    );
    page.graphics.drawString(pageNumber.toString(), PdfTrueTypeFont(fontAsset!.buffer.asUint8List(), 17),
        brush: PdfBrushes.white,
        format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
        bounds: Rect.fromLTWH(pageSize.width / 2 - circleSize / 2, bodyHeight + circleSize / 2, circleSize, circleSize));
  }

  Future<void> generatePdf() async {
    //Create a new PDF document.
    final PdfDocument document = PdfDocument();
    document.pageSettings.margins.top = 20;
    document.pageSettings.margins.bottom = 20;
    document.pageSettings.margins.right = 30;
    document.pageSettings.margins.left = 30;

    final double circleSize = 30;
    final double footerHeight = 40;
    final double sectionSpacing = 20;
    final double borderSize = 1;
    final double avatarSize = 60;
    final double textFontSize = 13;

    fontAsset = await rootBundle.load('fonts/MyriadPro-Regular.ttf');

    PdfPage? currentPage = null;
    int pageNumber = 3;
    for (var anecdote in anecdotes) {
      var imgBytes = (await http.get(Uri.parse(anecdote.imageUri ?? ""))).bodyBytes;
      var img = await decodeImageFromList(imgBytes);

      if (currentPage == null) {
        currentPage = document.pages.add();
        final Size pageSize = currentPage.getClientSize();
        final double bodyHeight = pageSize.height - footerHeight;
        final double sectionHeight = bodyHeight / 2 - sectionSpacing / 2;
        final double sectionWidth = pageSize.width;

        if (img.width > img.height) {
          await _drawAnecdoteLandscapeTop(currentPage, sectionWidth, sectionHeight, borderSize, avatarSize, textFontSize, anecdote, imgBytes);
        } else {
          await _drawAnecdotePortraitTop(currentPage, sectionWidth, sectionHeight, borderSize, avatarSize, textFontSize, anecdote, imgBytes);
        }

        //_drawPageNumber(currentPage, circleSize, bodyHeight - sectionSpacing / 4, pageNumber++);
      } else {
        final Size pageSize = currentPage.getClientSize();
        final double bodyHeight = pageSize.height - footerHeight;
        final double sectionHeight = bodyHeight / 2 - sectionSpacing / 2;
        final double sectionWidth = pageSize.width;

        if (img.width > img.height) {
          await _drawAnecdoteLandscapeBottom(
              currentPage, sectionWidth, sectionHeight, borderSize, avatarSize, textFontSize, sectionSpacing, anecdote, imgBytes);
        } else {
          await _drawAnecdotePortraitBottom(
              currentPage, sectionWidth, sectionHeight, borderSize, avatarSize, textFontSize, sectionSpacing, anecdote, imgBytes);
        }

        currentPage = null;
      }
    }

    // Save the document.
    final List<int> bytes = await document.save();
    html.AnchorElement(href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
      ..setAttribute('download', "generated.pdf")
      ..click();

    // Dispose the document.
    document.dispose();
  }

  void showNextAnecdote() {
    if (_selectedIndex + 1 < anecdotes.length) {
      selectedIndex++;
    }
  }

  void showPrevAnecdote() {
    if (_selectedIndex > 0) {
      selectedIndex--;
    }
  }

  Future<void> deleteSelectedAnecdote() async {
    await PocketbaseService.to.deleteAnecdote(anecdotes[_selectedIndex]);
    anecdotes.removeAt(_selectedIndex);
    _selectedIndex = -1;
    Get.back();
  }

  void _copyText(String text) async {
    if (_clipboard != null) {
      final item = DataWriterItem();
      item.add(Formats.plainText(text));
      try {
        await _clipboard!.write([item]);
      } catch (e) {
        Get.showSnackbar(
          GetSnackBar(
            title: "Erreur de copie",
            message: "Impossible de copier le texte",
            backgroundColor: Colors.red,
            icon: const Icon(Icons.done, color: Color(0xFFFFFFFF)),
            duration: const Duration(seconds: 3),
            onTap: (snack) => Get.back(closeOverlays: true),
          ),
        );
      }
    }
  }

  void _copyImage(String? uri, String name) async {
    if (_clipboard != null) {
      http.Response response = await http.get(
        Uri.parse(uri ?? ""),
      );
      final item = DataWriterItem(suggestedName: '${anecdotes[_selectedIndex].id}.png');
      item.add(Formats.png(response.bodyBytes));
      try {
        await _clipboard!.write([item]);
      } catch (e) {
        Get.showSnackbar(
          GetSnackBar(
            title: "Erreur de copie",
            message: "Impossible de copier l'image",
            backgroundColor: Colors.red,
            icon: const Icon(Icons.done, color: Color(0xFFFFFFFF)),
            duration: const Duration(seconds: 3),
            onTap: (snack) => Get.back(closeOverlays: true),
          ),
        );
      }
    }
  }

  void copyName() async {
    _copyText(getSelectedName());
  }

  void copyDate() async {
    _copyText(getSelectedDate());
  }

  void copyText() async {
    _copyText(getSelectedText());
  }

  void copyImageAnecdote() async {
    _copyImage(anecdotes[_selectedIndex].imageUri, '${anecdotes[_selectedIndex].id}.png');
  }

  void copyUserAvatar() async {
    _copyImage(anecdotes[_selectedIndex].user!.avatarUri, '${anecdotes[_selectedIndex].user!.username}.png');
  }

  Future<void> downloadImage() async {
    await WebImageDownloader.downloadImageFromWeb(anecdotes[_selectedIndex].imageUri ?? "",
        name: new DateFormat("yyyy-MM-dd", "fr-FR").format(anecdotes[_selectedIndex].date!).replaceAll("/", "-") +
            " " +
            anecdotes[_selectedIndex].user!.firstname,
        imageType: ImageType.jpeg,
        imageQuality: 0.95);
  }

  Future<void> downloadAllImages() async {
    for (var anecdote in anecdotes) {
      await WebImageDownloader.downloadImageFromWeb(anecdote.imageUri ?? "",
          name: new DateFormat("yyyy-MM-dd", "fr-FR").format(anecdote.date!).replaceAll("/", "-") + " " + anecdote.user!.firstname,
          imageType: ImageType.jpeg,
          imageQuality: 0.95);
    }
  }

  Future<void> downloadUserAvatar() async {
    await WebImageDownloader.downloadImageFromWeb(anecdotes[_selectedIndex].user!.avatarUri ?? "", name: anecdotes[_selectedIndex].user!.username);
  }

  String getId(int index) {
    return anecdotes[index].id;
  }

  String getImage(int index) {
    return anecdotes[index].getResizedImage(200, 200, false);
  }

  String getSelectedId() {
    if (_selectedIndex < 0) {
      return "";
    }
    return getId(_selectedIndex);
  }

  String getSelectedText() {
    if (_selectedIndex < 0) {
      return "";
    }
    return anecdotes[_selectedIndex].text;
  }

  String getSelectedName() {
    if (_selectedIndex < 0) {
      return "";
    }
    return (anecdotes[_selectedIndex].user?.firstname ?? "") + " " + (anecdotes[_selectedIndex].user?.lastname.capitalizeFirstLetter() ?? "");
  }

  String getSelectedDate() {
    if (_selectedIndex < 0) {
      return "";
    }
    return new DateFormat.MMMMd("fr_FR").format(anecdotes[_selectedIndex].date!).capitalizeFirstLetter();
  }

  String getSelectedImage() {
    if (_selectedIndex < 0) {
      return "";
    }
    return getImage(_selectedIndex);
  }

  String getSelectedUserAvatar() {
    if (_selectedIndex < 0) {
      return "";
    }
    return anecdotes[_selectedIndex].user?.getResizedAvatar() ?? "";
  }

  bool isFirstAnecdote() {
    return _selectedIndex == 0;
  }

  bool isLastAnecdote() {
    return _selectedIndex == anecdotes.length - 1;
  }

  set selectedIndex(int value) {
    _selectedIndex = value;
    update();
  }

  int get selectedIndex => _selectedIndex;
}
