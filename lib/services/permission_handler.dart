import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermissions() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}
