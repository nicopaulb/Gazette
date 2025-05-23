class DrawerModel {
  String? title;
  String? image;

  DrawerModel({this.image, this.title});
}

List<DrawerModel> getDrawerOptions() {
  List<DrawerModel> list = [];

  list.add(DrawerModel(image: 'images/gazette/icons/ic_Profile.png', title: 'Profil'));
  list.add(DrawerModel(image: 'images/gazette/icons/ic_Settings.png', title: 'Paramètres'));
  list.add(DrawerModel(image: 'images/gazette/icons/ic_Logout.png', title: 'Se déconnecter'));

  return list;
}
