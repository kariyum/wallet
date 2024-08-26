import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  late Future<List<NotificationModel>> notificationsFuture;
  late List<NotificationModel>? notifications;
  bool initialized = false;

  @override
  void initState() {
    notificationsFuture = AwesomeNotifications().listScheduledNotifications();
    super.initState();
  }

  bool _allowNotifications = true;
  bool _hasNotifications = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70.0,
        title: const Text("Notifications"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder(
        future: notificationsFuture,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (!initialized) {
                notifications = snapshot.data;
                initialized = true;
                _allowNotifications = notifications?.isNotEmpty ?? false;
              }
              if (notifications == null)
                return const Text("Couldn't get notifications");
              // data is ready
              final notification =
                  notifications!.firstOrNull?.schedule?.toMap();
              debugPrint("$notification");
              if (notification != null) {
                _time = TimeOfDay(
                    hour: notification["hour"], minute: notification["minute"]);
              }
              return body(context, notifications!);
            case ConnectionState.none:
              return const Center(child: Text("None"));
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.active:
              return const Text("Active");
          }
        },
      ),
    );
  }

  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    final pickedTime = showTimePicker(
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? Container(),
        );
      },
      context: context,
      initialTime: TimeOfDay.now(),
    );
    return pickedTime;
  }

  Widget digitContainer(int digit) {
    return Container(
      padding: EdgeInsets.all(4.0),
      child: Text(
        "$digit".padLeft(2, "0"),
        style: TextStyle(
            fontSize: 14, color: Theme.of(context).colorScheme.primary),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  TimeOfDay? _time;

  Future<bool> askForPermission() {
    return AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        return AwesomeNotifications().requestPermissionToSendNotifications();
      }
      return Future.value(true);
    });
  }

  Future scheduleNotification(BuildContext context, TimeOfDay time) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 33,
        channelKey: 'basic_channel',
        title: 'Remember to track your income and expenses!',
        // body: 'Call me :D',
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: time.hour,
        minute: time.minute,
        repeats: true,
      ),
    );
    AwesomeNotifications().listScheduledNotifications().then((value) {
      setState(() {
        debugPrint("Setting state");
        notifications = value;
      });
    });

    debugPrint("${time.hour} ${time.minute}");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification scheduled! 😊'),
        ),
      );
    }
  }

  Future cancelAllNotifications(BuildContext context) async {
    debugPrint("Cancelling all notifications");
    await AwesomeNotifications().cancelAllSchedules();
    AwesomeNotifications().listScheduledNotifications().then((value) {
      notifications = value;
    });
  }

  Widget timeWidget(BuildContext context) {
    return TapRegion(
      onTapInside: (value) async {
        final chosenTime = await _selectTime(context);
        if (chosenTime != null) {
          setState(() {
            _time = chosenTime;
          });
          final isPermitted = await askForPermission();
          if (isPermitted && context.mounted) {
            scheduleNotification(context, chosenTime);
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Did not get permission 😞'),
              ),
            );
          }
        }
      },
      child: SizedBox(
          width: 60,
          height: 30,
          child: Row(
            children: [
              digitContainer(_time?.hour ?? TimeOfDay.now().hour),
              const Text(" : "),
              digitContainer(_time?.minute ?? TimeOfDay.now().minute),
            ],
          )),
    );
  }

  Widget previous() {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await AwesomeNotifications()
                  .isNotificationAllowed()
                  .then((isAllowed) {
                if (!isAllowed) {
                  AwesomeNotifications().requestPermissionToSendNotifications();
                }
              });
              String localTimeZone =
                  await AwesomeNotifications().getLocalTimeZoneIdentifier();
              String utcTimeZone =
                  await AwesomeNotifications().getLocalTimeZoneIdentifier();
              await AwesomeNotifications()
                  .isNotificationAllowed()
                  .then((isAllowed) {
                debugPrint("Is notification allowed? ${isAllowed}");
                if (isAllowed) {
                  AwesomeNotifications().createNotification(
                    content: NotificationContent(
                        id: 22,
                        channelKey: 'basic_channel',
                        title:
                            'Scheduled after 10! Remember to track your expenses!',
                        body: 'What did you buy today, you dirty little boy?',
                        wakeUpScreen: true,
                        category: NotificationCategory.Reminder,
                        notificationLayout: NotificationLayout.Default),
                    schedule: NotificationCalendar.fromDate(
                      date: DateTime.now().add(Duration(seconds: 10)),
                    ),
                  );
                }
              });
            },
            child: const Text("Schedule after 10 seconds"),
          ),
          ElevatedButton(
            onPressed: () async {
              //check permission
              // await Future.delayed(Duration(seconds: 2)).then((value) {
              //   debugPrint("SENDING NOTIFICATION!");
              //   return AwesomeNotifications()
              //       .isNotificationAllowed()
              //       .then((isAllowed) {
              //     if (!isAllowed) {
              //       AwesomeNotifications()
              //           .requestPermissionToSendNotifications();
              //     }
              //   });
              // });
              //
              await AwesomeNotifications()
                  .isNotificationAllowed()
                  .then((isAllowed) {
                if (!isAllowed) {
                  AwesomeNotifications().requestPermissionToSendNotifications();
                }
              });
              // await AwesomeNotifications().createNotification(
              //   content: NotificationContent(
              //       id: 10,
              //       channelKey: 'basic_channel',
              //       title: 'Hello!',
              //       body: 'This is a simple notification',
              //       category: NotificationCategory.Reminder,
              //       notificationLayout: NotificationLayout.Default),
              // );
              String localTimeZone =
                  await AwesomeNotifications().getLocalTimeZoneIdentifier();
              String utcTimeZone =
                  await AwesomeNotifications().getLocalTimeZoneIdentifier();
              Future<TimeOfDay?> _selectTime(BuildContext context) async {
                final pickedTime = showTimePicker(
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(alwaysUse24HourFormat: true),
                      child: child ?? Container(),
                    );
                  },
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                return pickedTime;
              }

              if (context.mounted) {
                final time = await _selectTime(context);
                if (time != null) {
                  await AwesomeNotifications().createNotification(
                    content: NotificationContent(
                      id: 33,
                      channelKey: 'basic_channel',
                      title: 'Remember to track your expenses!',
                      body: 'What did you buy today, you dirty little boy?',
                      wakeUpScreen: true,
                      category: NotificationCategory.Reminder,
                      notificationLayout: NotificationLayout.Default,
                    ),
                    schedule: NotificationCalendar(
                      hour: time.hour,
                      minute: time.minute,
                      repeats: true,
                    ),
                  );
                  debugPrint("${time.hour} ${time.minute}");
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification scheduled!}'),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text("Schedule Notification"),
          ),
        ],
      ),
    );
  }



  Widget body(BuildContext context, List<NotificationModel> notifications) {
    _hasNotifications = notifications.isNotEmpty;
    return Column(
      children: [
        ListTile(
          title: Text("Allow Notifications"),
          leading: Icon(Icons.notifications),
          trailing: Switch(
              value: _allowNotifications,
              onChanged: (value) {
                if (!value) {
                  cancelAllNotifications(context).then((value) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cancelled All Notifications 😊'),
                        ),
                      );
                    }
                  });
                }
                setState(() {
                  _allowNotifications = value;
                });
              }),
        ),
        if (_allowNotifications)
          Container(
            decoration: BoxDecoration(color: () {
              if (!_hasNotifications) {
                return const Color.fromRGBO(213, 213, 213, 1.0);
              } else {
                return null;
              }
            }()),
            child: ListTile(
              leading: const Icon(Icons.timer),
              title: const Text("Daily Reminder At "),
              trailing: timeWidget(context),
            ),
          ),
        if (!_hasNotifications && _allowNotifications)
          const ListTile(
              dense: true,
              title: Text(
                "⚠️ Notification is not set up! Please choose a time",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ))
      ],
    );
  }
}
// Container(
// width: 200,
// child: TextField(
// controller: _timeController,
// onTap: () async {
// // selectTimeField(timeController);
// },
// canRequestFocus: false,
// showCursor: false,
// autofocus: false,
// readOnly: true,
// decoration: InputDecoration(
// alignLabelWithHint: true,
// labelText: 'Time',
// labelStyle: const TextStyle(
// fontSize: 17,
// ),
// suffixIcon: Padding(
// padding: const EdgeInsets.all(8.0),
// child: IconButton(
// icon: const Icon(
// Icons.access_time_outlined,
// ),
// onPressed: () async {
// // selectTimeField(timeController);
// },
// ),
// ),
// border: const OutlineInputBorder(),
// ),
// ),
// )
