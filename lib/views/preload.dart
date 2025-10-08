import 'package:get/get.dart';
import 'package:therepist/views/auth/auth_service.dart';

Future<void> preload() async {
  await Get.putAsync(() => AuthService().init());
}
