class SVDrawerModel {
  String? title;
  String? image;

  SVDrawerModel({this.image, this.title});
}

List<SVDrawerModel> getDrawerOptions() {
  List<SVDrawerModel> list = [];

  list.add(SVDrawerModel(image: 'images/gazette/icons/ic_Profile.png', title: 'Profile'));
  list.add(SVDrawerModel(image: 'images/gazette/icons/ic_Star.png', title: 'Paramètres'));
  list.add(SVDrawerModel(image: 'images/gazette/icons/ic_Logout.png', title: 'Se déconnecter'));

  return list;
}
