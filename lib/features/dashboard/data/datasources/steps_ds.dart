import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class StepsDataSource {
  Future<PermissionStatus> checkPermission();
  Future<PermissionStatus> requestPermission();
  Future<bool> openSettings();
  Stream<int> get stepCountStream;
}

class StepsDataSourceImpl implements StepsDataSource {
  @override
  Future<PermissionStatus> checkPermission() async {
    return await Permission.activityRecognition.status;
  }

  @override
  Future<PermissionStatus> requestPermission() async {
    return await Permission.activityRecognition.request();
  }

  @override
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  @override
  Stream<int> get stepCountStream {
    return Pedometer.stepCountStream.map((event) => event.steps);
  }
}
