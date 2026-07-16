import 'package:get/get.dart';
import 'package:loyalty_customer/routes/app_routes.dart';
import 'package:loyalty_customer/screen/profile_section/profile_screen/model/profile_model.dart';
import 'package:loyalty_customer/service/api_service/get_storage_services.dart';
import 'package:loyalty_customer/service/repository/get_repository.dart';
import 'package:loyalty_customer/widget/app_log/app_print.dart';

class SplashController extends GetxController {
  final GetStorageServices storageServices = GetStorageServices.instance;
  final GetRepository getRepository = GetRepository.instance;

  Rxn<ProfileModelData> profileModelData = Rxn<ProfileModelData>();

  @override
  void onInit() {
    super.onInit();
    onInitialDataLoadScreen();
  }

  Future<void> onInitialDataLoadScreen() async {
    try {
      await Future.wait([
        Future.delayed(const Duration(seconds: 3)),
        _fetchInitialData(),
      ]);

      _handleNavigation();
    } catch (e) {
      AppPrint.appError(e, title: "onInitialDataLoadScreen");
      Get.offAllNamed(AppRoutes.instance.onBoardingScreen);
    }
  }

  // টোকেন থাকলে প্রোফাইল ডেটা নিয়ে আসার ফাংশন
  Future<void> _fetchInitialData() async {
    final String token = storageServices.getToken();
    if (token.isNotEmpty) {
      await getSubscription();
    }
  }

  // নেভিগেশন লজিক (যেখানে সব কন্ডিশন চেক হবে)
  void _handleNavigation() {
    final String token = storageServices.getToken();

    // টোকেন না থাকলে সরাসরি অনবোর্ডিং
    if (token.isEmpty) {
      if (storageServices.getIsUserFirstTime() == true) {
        Get.offAllNamed(AppRoutes.instance.authScreen);
      } else {
        Get.offAllNamed(AppRoutes.instance.onBoardingScreen);
      }
      return;
    }

    final data = profileModelData.value;

    // ১. লোকেশন চেক (Null safety এবং empty coordinates চেক)
    bool isLocationEmpty =
        data?.location?.coordinates == null ||
        data!.location!.coordinates!.isEmpty ||
        data.location!.coordinates!.any((e) => e == 0.0 || e == null);

    if (isLocationEmpty) {
      Get.offAllNamed(AppRoutes.instance.locationScreen);
      return;
    }

    // ২. ইউজার ওয়েটিং লিস্টে আছে কিনা
    if (data.isUserWaiting == true) {
      Get.offAllNamed(AppRoutes.instance.waitingScreen);
      return;
    }

    // ৩. সাবস্ক্রিপশন চেক
    if (data?.subscription == "active") {
      Get.offAllNamed(AppRoutes.instance.navigationScreen);
    } else {
      // সাবস্ক্রিপশন একটিভ না থাকলে পেমেন্ট/সাবস্ক্রিপশন স্ক্রিন
      Get.offAllNamed(AppRoutes.instance.mySubScreen, arguments: {'value': 1});
    }
  }

  // প্রোফাইল ডেটা API থেকে ফেচ করার ফাংশন
  Future<void> getSubscription() async {
    try {
      final response = await getRepository.getProfile();
      if (response != null) {
        profileModelData.value = response;
        AppPrint.apiResponse(
          profileModelData.value?.subscription ?? "No Subscription Found",
          title: "Splash Profile Status",
        );
      }
    } catch (e) {
      AppPrint.appError(e, title: "getSubscription API Call Failed");
    }
  }
}


