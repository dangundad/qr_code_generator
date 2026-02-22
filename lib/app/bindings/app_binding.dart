import 'package:get/get.dart';

import 'package:qr_code_generator/app/controllers/qr_controller.dart';
import 'package:qr_code_generator/app/services/hive_service.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HiveService>()) {
      Get.put(HiveService(), permanent: true);
    }

    if (!Get.isRegistered<QrController>()) {
      Get.put(QrController(), permanent: true);
    }
  }
}
