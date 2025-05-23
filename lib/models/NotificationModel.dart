import 'package:gazette/utils/Constants.dart';

class NotificationModel {
  String? name;
  String? secondName;
  String? profileImage;
  String? time;
  String? notificationType;
  String? postImage;
  bool? isOfficial;
  String? birthDate;

  NotificationModel(
      {this.name,
      this.profileImage,
      this.time,
      this.notificationType,
      this.postImage,
      this.isOfficial,
      this.secondName,
      this.birthDate});
}

List<NotificationModel> getNotificationsToday() {
  List<NotificationModel> list = [];

  list.add(NotificationModel(
    name: 'Jane_Cooper',
    time: '2 min',
    profileImage: 'images/gazette/faces/face_1.png',
    notificationType: NotificationType.like,
    postImage: 'images/gazette/posts/post_one.png',
    isOfficial: false,
  ));
  list.add(NotificationModel(
    name: 'Bea_Mine',
    time: '2 min',
    profileImage: 'images/gazette/faces/face_2.png',
    notificationType: NotificationType.request,
    isOfficial: false,
  ));

  return list;
}

List<NotificationModel> getNotificationsThisMonth() {
  List<NotificationModel> list = [];

  list.add(NotificationModel(
    name: 'Anne Ortha',
    time: '2 week',
    profileImage: 'images/gazette/faces/face_3.png',
    notificationType: NotificationType.like,
    postImage: 'images/gazette/posts/post_two.png',
    isOfficial: true,
  ));
  list.add(NotificationModel(
    name: 'Anne Ortha',
    secondName: 'Dee Zynah',
    time: '2 week',
    profileImage: 'images/gazette/faces/face_1.png',
    notificationType: NotificationType.birthday,
    isOfficial: true,
    birthDate: '25 March',
  ));
  list.add(NotificationModel(
    name: 'Bea_Mine',
    time: '2 week',
    profileImage: 'images/gazette/faces/face_2.png',
    notificationType: NotificationType.request,
    isOfficial: false,
  ));
  list.add(NotificationModel(
    name: 'B. Homesoon',
    time: '2 week',
    profileImage: 'images/gazette/faces/face_4.png',
    notificationType: NotificationType.newPost,
    postImage: 'images/gazette/posts/post_three.png',
    isOfficial: true,
  ));

  return list;
}

List<NotificationModel> getNotificationsEarlier() {
  List<NotificationModel> list = [];

  list.add(NotificationModel(
    name: 'Anne Ortha',
    secondName: 'Dee Zynah',
    time: '2 week',
    profileImage: 'images/gazette/faces/face_5.png',
    notificationType: NotificationType.birthday,
    isOfficial: true,
    birthDate: '05 Feb',
  ));
  return list;
}
