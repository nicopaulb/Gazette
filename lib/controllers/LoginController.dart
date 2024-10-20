import 'package:get/get.dart';
import 'package:gazette/services/PocketBaseService.dart';

class LoginController extends GetxController {
  Future<String?> onLogin(String username, String password) async {
    try {
      await PocketbaseService.to.login(username, password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
