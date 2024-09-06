import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chess_game/screen/home_screen.dart';
import 'package:chess_game/screen/homepage.dart';
import 'package:flutter/material.dart';

import 'main.dart';


class NotificationService {
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        null, //'resource://drawable/res_app_icon',//
        [
          NotificationChannel(
            channelGroupKey: "high_importance_channel",
              channelKey: 'high_importance_channel',
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              playSound: true,
              onlyAlertOnce: true,
              criticalAlerts: true,
              channelShowBadge: true,
              groupAlertBehavior: GroupAlertBehavior.Children,
              importance: NotificationImportance.High,
              defaultPrivacy: NotificationPrivacy.Private,
              defaultColor: Colors.deepPurple,
              ledColor: Colors.deepPurple)
        ],
        channelGroups: [
          NotificationChannelGroup(
              channelGroupKey: 'high_importance_channel_group',
              channelGroupName: 'Group 1')
        ],
        debug: true);
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // Request permission if not already granted
      isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    if (isAllowed) {
      await AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onNotificationCreatedMethod: onNotificationCreatedMethod,
        onNotificationDisplayedMethod: onNotificationDisplayedMethod,
        onDismissActionReceivedMethod: onDismissActionReceivedMethod,
      );
    } else {
      debugPrint('User did not grant permission for notifications');
    }
  }

  static Future<void>onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async{
    debugPrint('onNotificationCreatedMethod');
  }
  static Future<void>onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async{
    debugPrint('onDismissActionReceivedMethod');
  }
  static Future<void>onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async{
    debugPrint('onNotificationDisplayedMethod');
  }
  static Future<void>onActionReceivedMethod(
      ReceivedAction receivedAction) async{
    debugPrint('onActionReceivedMethod');
    final payload = receivedAction.payload ?? {};
    if(payload["navigate"] == "true"){
      MyApp.navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_)=>const Homepage())
      );
    }
  }
  static Future<void> showNotification({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final int? interval,
  }) async {
    assert(!scheduled || (scheduled && interval != null));
    await AwesomeNotifications().createNotification (
      content: NotificationContent (
      id: -1,
      channelKey: 'high_importance_channel',
      title: title,
      body: body,
      actionType: actionType,
      notificationLayout: notificationLayout,
      summary: summary,
      category: category,
      payload: payload,
      bigPicture: bigPicture,
      ),
      actionButtons: actionButtons,
      schedule: scheduled
          ? NotificationInterval(
          interval: interval,
          timeZone:
          await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        preciseAlarm: true,
    )
  :null
    );
  }
}

class NotificationButton extends StatelessWidget {
  const NotificationButton({
    required this.onPressed,
    required this.text,
    super.key,
  });
  final VoidCallback onPressed;
  final String text;
  @override
  Widget build (BuildContext context) {
    return Padding (
      padding: const EdgeInsets.only(
        left: 30.0,
        right: 30.0,
        top: 20,
        bottom: 10,
      ), // EdgeInsets.only
    child: SizedBox(
      width: MediaQuery. of (context).size.width,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shadowColor: Theme. of (context).shadowColor,
          backgroundColor: Theme. of (context). primaryColor,
        ),
        onPressed: onPressed,
        child: Text (text),
      ), // ElevatedButton
    ), // SizedBox
    ); // Padding
  }
}
