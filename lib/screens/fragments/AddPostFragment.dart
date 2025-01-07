import 'package:flutter/material.dart';
import 'package:gazette/controllers/AddAnecdoteController.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:gazette/utils/SVConstants.dart';
import 'package:gazette/utils/SVColors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AddPostFragment extends StatelessWidget {
  final AddAnecdoteController _addAnecdoteController = Get.put(AddAnecdoteController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cardColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: ContextExtensions(context).iconColor),
        backgroundColor: svGetScaffoldColor(),
        title: Text('Nouvelle anecdote', style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        leading: GetBuilder<AddAnecdoteController>(
          builder: (_) => _addAnecdoteController.openedAnecdote == null
              ? Container()
              : IconButton(
                  icon: Icon(
                    Icons.delete,
                  ),
                  onPressed: () => _addAnecdoteController.deleteAnecdote(),
                ),
        ),
        actions: [
          GetBuilder<AddAnecdoteController>(
            builder: (_) => AppButton(
              shapeBorder: RoundedRectangleBorder(borderRadius: radius(4)),
              text: _addAnecdoteController.openedAnecdote == null ? 'Envoyer' : 'Modifier',
              textStyle: boldTextStyle(color: Colors.white, size: 12),
              onTap: () => _addAnecdoteController.openedAnecdote == null
                  ? _addAnecdoteController.sendNewAnecdote()
                  : _addAnecdoteController.sendUpdatedAnecdote(),
              elevation: 0,
              color: SVAppColorPrimary,
              width: 100,
              padding: EdgeInsets.all(0),
            ).paddingAll(8),
          )
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
                    decoration: BoxDecoration(color: svGetScaffoldColor(), borderRadius: radius(SVAppCommonRadius)),
                    child: Form(
                      key: _addAnecdoteController.formKey,
                      child: TextFormField(
                        controller: _addAnecdoteController.contentTextController,
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
                          hintStyle: secondaryTextStyle(size: 14, color: svGetBodyColor()),
                        ),
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.all(4),
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(color: svGetScaffoldColor(), borderRadius: radius(SVAppCommonRadius)),
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
                                  style: secondaryTextStyle(color: _addAnecdoteController.getSelectedImageNameColor()),
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
                      decoration: BoxDecoration(color: svGetScaffoldColor(), borderRadius: radius(SVAppCommonRadius)),
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
                  SizedBox(
                      height: 75,
                      child: GetBuilder<AddAnecdoteController>(
                          builder: (_) => Row(
                                children: [
                                  10.width,
                                  Container(
                                    width: 75,
                                    height: 75,
                                    decoration: BoxDecoration(
                                        border: _addAnecdoteController.openedAnecdote == null ? Border.all(color: SVAppColorPrimary, width: 6) : null,
                                        borderRadius: BorderRadius.circular(16)),
                                    child: InkWell(
                                      onTap: () => _addAnecdoteController.openAnecdote(-1),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                            padding: EdgeInsets.all(17),
                                            color: svGetScaffoldColor(),
                                            child: Image.asset('images/gazette/add.png', height: 35, width: 35, fit: BoxFit.fill, color: blackColor)),
                                      ),
                                    ),
                                  ),
                                  5.width,
                                  VerticalDivider(
                                    thickness: 1,
                                    color: svGetBodyColor(),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: false,
                                        itemCount: _addAnecdoteController.submittedAnecdotes.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            width: 75,
                                            height: 75,
                                            margin: EdgeInsets.symmetric(horizontal: 5),
                                            decoration: BoxDecoration(
                                                border: _addAnecdoteController.isAnecdoteOpened(index)
                                                    ? Border.all(color: SVAppColorPrimary, width: 6)
                                                    : null,
                                                borderRadius: BorderRadius.circular(16)),
                                            child: InkWell(
                                              onTap: () => _addAnecdoteController.openAnecdote(index),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: CachedNetworkImage(
                                                    imageUrl: _addAnecdoteController.submittedAnecdotes[index].imageUri ?? "",
                                                    fit: BoxFit.cover,
                                                    width: 75,
                                                    height: 75),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                ],
                              ))),
                  10.height
                ],
              ),
            )),
    );
  }
}
