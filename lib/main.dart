import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:therepist/firebase_options.dart';
import 'package:therepist/models/appointment_model.dart';
import 'package:therepist/utils/config/app_config.dart';
import 'package:therepist/utils/routes/route_methods.dart';
import 'package:therepist/utils/routes/route_name.dart';
import 'package:therepist/utils/service/notification_service.dart';
import 'package:therepist/utils/storage.dart';
import 'package:therepist/utils/theme/light.dart';
import 'package:therepist/views/dashboard/home/appointments/appointments.dart';
import 'package:therepist/views/preload.dart';
import 'package:therepist/views/restart.dart';
import 'package:toastification/toastification.dart';
import 'views/dashboard/home/home_ctrl.dart';

Future<void> main() async {
  await GetStorage.init();
  GestureBinding.instance.resamplingEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Color(0xFF10B981), statusBarIconBrightness: Brightness.light));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await preload();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _firebaseMessagingBackgroundHandler(message);
  });
  terminatedNotification();
  runApp(const RestartApp(child: MyApp()));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  String? lastHandledMessageId = await read('notificationKey');
  if (message.messageId != null && message.messageId != lastHandledMessageId) {
    await write('notificationKey', message.messageId);
    await notificationService.init();
    if (Get.currentRoute != AppRouteNames.dashboard) {
      Get.offAllNamed(AppRouteNames.dashboard);
    }
    if (message.notification?.title == "New Request" || message.data['type'] == "Reject Appointment") {
      Future.delayed(const Duration(milliseconds: 500), () async {
        final ctrl = Get.isRegistered<HomeCtrl>() ? Get.find<HomeCtrl>() : Get.put(HomeCtrl());
        await ctrl.loadAppointments();
        List<AppointmentModel> appointmentModel = ctrl.pendingAppointments.where((e) => e.id == message.data["requestId"].toString()).toList();
        if (message.notification?.title == 'Reject Appointment') {
          Get.to(() => const Appointments(), transition: Transition.rightToLeft);
        } else {
          ctrl.showAppointmentCountdownPopup(appointmentModel.first);
        }
      });
    }
  }
}

Future<void> terminatedNotification() async {
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  String? lastHandledMessageId = await read('notificationKey');
  if (initialMessage != null && initialMessage.messageId != lastHandledMessageId) {
    await write('notificationKey', initialMessage.messageId);
    if (Get.currentRoute != AppRouteNames.dashboard) {
      Get.offAllNamed(AppRouteNames.dashboard);
    }
    Future.delayed(const Duration(milliseconds: 500), () async {
      final ctrl = Get.isRegistered<HomeCtrl>() ? Get.find<HomeCtrl>() : Get.put(HomeCtrl());
      await ctrl.loadAppointments();
      List<AppointmentModel> appointmentModel = ctrl.pendingAppointments.where((e) => e.id == initialMessage.data["requestId"].toString()).toList();
      if (initialMessage.notification?.title == 'Reject Appointment') {
        Get.to(() => const Appointments(), transition: Transition.rightToLeft);
      } else {
        ctrl.showAppointmentCountdownPopup(appointmentModel.first);
      }
    });
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        builder: (BuildContext context, widget) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: widget!,
          );
        },
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.system,
        getPages: AppRouteMethods.pages,
        initialRoute: AppRouteNames.splash,
      ),
    );
  }
}
