import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:sonr_app/env.dart';
import 'package:sonr_app/style/style.dart';
import 'dart:async';

class HelperService extends GetxService {
  static bool get isRegistered => Get.isRegistered<HelperService>();
  static HelperService get to => Get.find<HelperService>();

  final isFirebaseReady = false.obs;
  final isIntercomReady = false.obs;

  Future<HelperService> init() async {
    return this;
  }

  static Future<void> openIntercom() async {
    if (DeviceService.isMobile && isRegistered) {
      if (await Permissions.Notifications.isGranted) {
        await Intercom.displayMessenger();
      } else {
        await to._setupCloudMessaging();
        await to._setupIntercom();
        await Intercom.displayMessenger();
      }
    }
  }

  Future<void> _setupCloudMessaging() async {
    if (DeviceService.isMobile) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      isFirebaseReady(true);
    }
  }

  Future<void> _setupIntercom() async {
    if (DeviceService.isMobile) {
      // Set Api
      await Intercom.initialize(
        Env.icom_appID,
        iosApiKey: Env.icom_iosKey,
        androidApiKey: Env.icom_androidKey,
      );

      // Setup Token
      final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        Intercom.sendTokenToIntercom(token);
        isIntercomReady(true);
      }
    }
  }
}