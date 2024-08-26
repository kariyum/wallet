// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class NotificationService {
//   final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   Future<void> initNotification() async {
//     AndroidInitializationSettings androidInitializationSettings = const AndroidInitializationSettings("drawable-xxhdpi/ic_launcher_foreground.png");
//     final initializationSettings = InitializationSettings(android: androidInitializationSettings);
//     await notificationsPlugin.initialize(initializationSettings);
//   }
//
//   Future<void> sendNotification(Future<void> Function(FlutterLocalNotificationsPlugin, NotificationDetails) f) async {
//     const notificationDetails =  NotificationDetails(
//         android: AndroidNotificationDetails('channelId', 'channelName')
//     );
//     f(notificationsPlugin, notificationDetails);
//   }
// }

import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  Future<bool> sendNotification() async {
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    return AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'basic_channel',
          actionType: ActionType.Default,
          title: 'Hello World!',
          body: 'This is my first notification!',
        )
    );
  }
}