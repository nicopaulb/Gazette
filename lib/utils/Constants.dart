import 'package:google_fonts/google_fonts.dart';

const double AppContainerRadius = 32;
const double AppCommonRadius = 12;
const AppName = "Gazette";

class NotificationType {
  static String like = 'like';
  static String request = 'request';
  static String birthday = 'birthday';
  static String newPost = 'newPost';
}

class PostType {
  static String video = 'video';
  static String camera = 'camera';
  static String voice = 'voice';
  static String location = 'location';
  static String text = 'text';
}

var fontRoboto = GoogleFonts.roboto().fontFamily;
