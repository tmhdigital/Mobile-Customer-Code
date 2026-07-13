import 'package:get/get.dart';
import 'package:loyalty_customer/service/repository/get_repository.dart';
import 'package:loyalty_customer/widget/app_log/app_print.dart';

class PrivicyPolicyController extends GetxController {
  GetRepository getRepository = GetRepository.instance;

  String? privacy;
  String? content;

  RxBool isLoading = false.obs;

  Future<void> getRules() async {
    try {
      isLoading.value = true;
      final response = await getRepository.getRules(privacy ?? "");
      if (response != null) {
        content = response;
        AppPrint.apiResponse(content, title: "Rules content");
      }
    } catch (e) {
      AppPrint.appError(e, title: "Rules Error");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    privacy = _augumentRecived();
    getRules();
    super.onInit();
  }

  _augumentRecived() => Get.arguments['endpoint'];
}
