import 'package:flutter/material.dart';
import 'package:gazette/controllers/AddAnecdoteController.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:gazette/utils/SVConstants.dart';
import 'package:gazette/utils/SVColors.dart';

class AddPostFragment extends StatelessWidget {
  final AddAnecdoteController _addAnecdoteController =
      Get.put(AddAnecdoteController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cardColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: ContextExtensions(context).iconColor),
        backgroundColor: context.cardColor,
        title: Text('Nouvelle anecdote', style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        actions: [
          AppButton(
            shapeBorder: RoundedRectangleBorder(borderRadius: radius(4)),
            text: 'Envoyer',
            textStyle: boldTextStyle(color: Colors.white, size: 12),
            onTap: () => _addAnecdoteController.sendAnecdote(),
            elevation: 0,
            color: SVAppColorPrimary,
            width: 100,
            padding: EdgeInsets.all(0),
          ).paddingAll(8),
        ],
      ),
      body: Obx(() => _addAnecdoteController.isUploading.value
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              height: ContextExtensions(context).height(),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: svGetScaffoldColor(),
                        borderRadius: radius(SVAppCommonRadius)),
                    child: Form(
                      key: _addAnecdoteController.formKey,
                      child: TextFormField(
                        controller:
                            _addAnecdoteController.contentTextController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "L'anecdote ne peut pas être vide";
                          }
                          return null;
                        },
                        autofocus: false,
                        maxLines: 8,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Il était une fois...',
                          hintStyle: secondaryTextStyle(
                              size: 14, color: svGetBodyColor()),
                        ),
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.all(4),
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: svGetScaffoldColor(),
                          borderRadius: radius(SVAppCommonRadius)),
                      child: ListTile(
                        onTap: () {
                          _addAnecdoteController.pickerImage();
                        },
                        title: Text(
                          "Image",
                          style: primaryTextStyle(),
                        ),
                        subtitle: GetBuilder<AddAnecdoteController>(
                            builder: (_) => Text(
                                  _addAnecdoteController.getSelectedImageName(),
                                  style: secondaryTextStyle(
                                      color: _addAnecdoteController
                                          .getSelectedImageNameColor()),
                                )),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.image,
                            color: ContextExtensions(context).iconColor,
                          ),
                          onPressed: () async {
                            _addAnecdoteController.pickerImage();
                          },
                        ),
                      )),
                  Container(
                      padding: EdgeInsets.all(4),
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: svGetScaffoldColor(),
                          borderRadius: radius(SVAppCommonRadius)),
                      child: ListTile(
                        onTap: () {
                          _addAnecdoteController.pickerDate(context);
                        },
                        title: Text(
                          'Date',
                          style: primaryTextStyle(),
                        ),
                        subtitle: GetBuilder<AddAnecdoteController>(
                            builder: (_) => Text(
                                  _addAnecdoteController.getSelectedDate(),
                                  style: secondaryTextStyle(),
                                )),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.date_range,
                            color: ContextExtensions(context).iconColor,
                          ),
                          onPressed: () {
                            _addAnecdoteController.pickerDate(context);
                          },
                        ),
                      )),
                  Spacer(),
                  GetBuilder<AddAnecdoteController>(
                      builder: (_) => Text(
                            "Anecdotes envoyées par ${_addAnecdoteController.getUserName()} : ${_addAnecdoteController.submittedAnecdotes.length}",
                            style: secondaryTextStyle(),
                          )),
                  10.height
                ],
              ),
            )),
    );
  }
}
