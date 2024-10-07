import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:telephony/telephony.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui';


var url = GetStorage().read('url') ?? 'https://luttecontreviechere.ci/api/sms';
var enabled = GetStorage().read('enabled') ?? false;

void backgrounMessageHandler(SmsMessage message) async {
  print('background message: ${message.body}');
  if(enabled){

  }
  Dio().post(url, data: {
    'contact': message.address,
    'message': message.body,
    'date': message.date,
  }).then((value) => print(value));

}


Future<void> initializeService() async {

  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: (service) async {
        final Telephony telephony = Telephony.instance;
        telephony.requestPhoneAndSmsPermissions.then((value) => print('permissions: $value'));
        DartPluginRegistrant.ensureInitialized();


        telephony.listenIncomingSms(
            onNewMessage: (SmsMessage message) {
              print('new message: ${message.body}');

              Dio().post(url, data: {
                'contact': message.address,
                'message': message.body,
                'date': message.date,
              }).then((value) => print("----------------- response: $value"));
            },
            onBackgroundMessage: backgrounMessageHandler
        );
      },

      // auto start service
      autoStart: true,
      isForegroundMode: true,

    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: (service) async {
        print('onForeground');
      },

      // you have to enable background fetch capability on xcode project
      onBackground: (service) async {
        print('onBackground');
        return true;
      },
    ),
  );

  service.startService();

}


void main() {

  WidgetsFlutterBinding.ensureInitialized();
  final Telephony telephony = Telephony.instance;
  telephony.requestPhoneAndSmsPermissions.then((value) => print('permissions: $value'));
  telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        print('new message: ${message.body}');

        Dio().post(url, data: {
          'contact': message.address,
          'message': message.body,
          'date': message.date,
        }).then((value) => print(value));
      },
      onBackgroundMessage: backgrounMessageHandler
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();


    return MaterialApp(
      title: 'SMS Gateway',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Center(
          child:  Column(
            children: [

            ],
          ),
        ),
      ),
    );
  }
}

void setUrl(String url) {
  GetStorage().write('url', url);
}
