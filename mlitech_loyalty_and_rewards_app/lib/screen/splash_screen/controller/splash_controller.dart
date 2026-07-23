import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:loyalty_customer/routes/app_routes.dart';
import 'package:loyalty_customer/screen/profile_section/profile_screen/model/profile_model.dart';
import 'package:loyalty_customer/service/api_service/get_storage_services.dart';
import 'package:loyalty_customer/service/repository/get_repository.dart';
import 'package:loyalty_customer/widget/app_log/app_print.dart';

class SplashController extends GetxController {
  final GetStorageServices storageServices = GetStorageServices.instance;
  final GetRepository getRepository = GetRepository.instance;

  // রিঅ্যাক্টিভ ভেরিয়েবলস
  Rxn<ProfileModelData> profileModelData = Rxn<ProfileModelData>();

  @override
  void onInit() {
    super.onInit();
    onInitialDataLoadScreen();
  }

  Future<void> onInitialDataLoadScreen() async {
    try {
      // টোকেন থাকলে প্রোফাইল/সাবস্ক্রিপশন ডেটা লোড করবে
      await _fetchInitialData();

      // ডেটা লোড হওয়ার পর নেভিগেশন ডিসিশন নেওয়া হবে
      _handleNavigation();
    } catch (e) {
      AppPrint.appError(e, title: "onInitialDataLoadScreen");
      // এরর হলে অনবোর্ডিং স্ক্রিনে পাঠিয়ে দেওয়া নিরাপদ
      _navigateTo(AppRoutes.instance.onBoardingScreen);
    }
  }

  /// Removes the native splash screen (kept alive since app launch) right
  /// before handing off to the resolved first screen, so only one splash
  /// is ever visible to the user.
  void _navigateTo(String route, {Object? arguments}) {
    FlutterNativeSplash.remove();
    Get.offAllNamed(route, arguments: arguments);
  }

  // টোকেন থাকলে প্রোফাইল ডেটা নিয়ে আসার ফাংশন
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
        _navigateTo(AppRoutes.instance.authScreen);
      } else {
        _navigateTo(AppRoutes.instance.onBoardingScreen);
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
      _navigateTo(AppRoutes.instance.locationScreen);
      return;
    }

    // ২. ইউজার ওয়েটিং লিস্টে আছে কিনা
    if (data.isUserWaiting == true) {
      _navigateTo(AppRoutes.instance.waitingScreen);
      return;
    }

    // ৩. সাবস্ক্রিপশন চেক
    if (data?.subscription == "active") {
      _navigateTo(AppRoutes.instance.navigationScreen);
    } else {
      // সাবস্ক্রিপশন একটিভ না থাকলে পেমেন্ট/সাবস্ক্রিপশন স্ক্রিন
      _navigateTo(AppRoutes.instance.mySubScreen, arguments: {'value': 1});
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
