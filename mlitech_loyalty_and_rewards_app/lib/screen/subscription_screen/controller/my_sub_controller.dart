import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loyalty_customer/routes/app_routes.dart';
import 'package:loyalty_customer/screen/home_screen/model/subscription_summery_model.dart';
import 'package:loyalty_customer/screen/profile_section/profile_screen/model/profile_model.dart';
import 'package:loyalty_customer/screen/subscription_screen/model/package_list_model.dart';
import 'package:loyalty_customer/screen/subscription_screen/model/stripe_checkout_model.dart';
import 'package:loyalty_customer/service/api_service/get_storage_services.dart';
import 'package:loyalty_customer/service/repository/get_repository.dart';
import 'package:loyalty_customer/service/repository/post_repository.dart';
import 'package:loyalty_customer/widget/app_log/app_print.dart';
import 'package:loyalty_customer/widget/app_snackbar/app_snack_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MySubController extends GetxController {
  final GetRepository _getRepository = GetRepository.instance;
  final PostRepository _postRepository = PostRepository.instance;

  TextEditingController tokenController = TextEditingController();
  GetStorageServices storageServices = GetStorageServices.instance;

  // Error code constants for iOS/Android network errors
  static const int _kNetworkNotAvailable = -1009; // iOS
  static const int _kCannotFindHost = -1003; // iOS

  // Observable lists and states
  RxList<PackageModel> packageList = <PackageModel>[].obs;
  Rxn<ProfileModelData> profileValue = Rxn<ProfileModelData>();
  RxBool isLoading = false.obs;
  RxBool isPaymentLoading = false.obs;

  // WebView related observables
  RxString stripeUrl = ''.obs;
  WebViewController? webViewController;

  // Flag to prevent multiple dialogs
  final RxBool _dialogShown = false.obs;
  final int value1 = Get.arguments['value'];

  @override
  void onInit() {
    tokenController = TextEditingController();
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;

    await Future.wait([
      getPackageList(showLoading: false),
      _refreshUserProfile(showLoading: false),
    ]);
    if (value1 == 1) {
      await getSubSummary();
    }
    // await getSubSummary(); // ✅

    isLoading.value = false;
  }

  @override
  void dispose() {
    tokenController.dispose();
    super.dispose();
  }

  // -------------- Subscription get package list --------------
  Future<void> getPackageList({bool showLoading = true}) async {
    if (showLoading) isLoading.value = true;
    final packageList = await _getRepository.getPackageList();
    if (packageList.isNotEmpty) {
      this.packageList.value = packageList;
    }
    if (showLoading) isLoading.value = false;
  }

  void salesRep({required String packageId}) async {
    final response = await _postRepository.salesRep(packageId: packageId);
    if (response) {
      Get.toNamed(AppRoutes.instance.waitingScreen);

      AppSnackBar.success("Sales Rep added successfully");
    } else {
      AppSnackBar.error("Failed to add Sales Rep");
    }
  }

  // -------------- Subscription payment with WebView --------------
  Future<void> paymentPackage({required String packageId}) async {
    try {
      isPaymentLoading.value = true;
      _dialogShown.value = false; // Reset dialog flag

      StripeCheckoutModel? response = await _postRepository.paymentPackage(
        packageId: packageId,
      );

      if (response != null &&
          response.success == true &&
          response.data?.url != null) {
        final url = response.data!.url!;
        stripeUrl.value = url;
        _initializeWebView(url);
        AppPrint.appLog("✅ Payment package URL received: $url");
      } else {
        AppSnackBar.success("You are already subscribed");

        Get.offAllNamed(
          AppRoutes.instance.navigationScreen,
        ); // this logic implementing by mahabub

        // _showErrorSnackbar('Failed to get checkout URL');
      }
    } catch (e) {
      _showErrorSnackbar('An error occurred: $e');
      AppPrint.appError(e, title: "Payment Package Error");
    } finally {
      isPaymentLoading.value = false;
    }
  }

  /// Initialize WebView with Stripe URL
  void _initializeWebView(String url) {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            AppPrint.appLog('📄 Stripe page started loading: $url');
          },
          onPageFinished: (String url) {
            AppPrint.appLog('✅ Stripe page finished loading: $url');
            _checkConnectionSuccess(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            AppPrint.appLog('🔗 Navigation to: ${request.url}');
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            AppPrint.appError('❌ WebView error: ${error.description}');
            // Platform-specific error handling for iOS and Android
            if (error.errorCode == _kNetworkNotAvailable ||
                error.errorCode == _kCannotFindHost) {
              Get.snackbar(
                'Connection Error',
                'Please check your internet connection',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.shade100,
                colorText: Colors.red.shade900,
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  /// Check if Stripe checkout was successful
  void _checkConnectionSuccess(String url) {
    // Prevent multiple dialogs
    if (_dialogShown.value) return;

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final path = uri.path.toLowerCase();

    // Success URL patterns
    final isSuccess =
        path.contains("success") ||
        path.contains("payment-success") ||
        path.contains("payment_success") ||
        uri.queryParameters["success"] == "true";

    // Return URL patterns
    final isReturn =
        path.contains("return") || uri.queryParameters.containsKey("return");

    if (isSuccess || isReturn) {
      _dialogShown.value = true;

      debugPrint("🎉 Payment Success Detected: $url");

      _showSuccessDialog();
    }
  }
  // void _checkConnectionSuccess(String url) {
  //   // Prevent multiple dialogs
  //   if (_dialogShown.value) return;

  //   // Check for success patterns in URL
  //   // Stripe typically redirects back after successful payment
  //   final uri = Uri.tryParse(url);
  //   if (uri != null) {
  //     // Check if URL contains success or return parameters from Stripe
  //     final hasSuccess =
  //         uri.path.contains('/success') ||
  //         uri.queryParameters.containsKey('success');
  //     final hasReturn =
  //         uri.path.contains('/return') ||
  //         uri.queryParameters.containsKey('return');

  //     if (hasSuccess || hasReturn) {
  //       _dialogShown.value = true;

  //       _showSuccessDialog();
  //     }
  //   }
  // }

  /// Show success dialog
  void _showSuccessDialog() {
    Get.offAllNamed(AppRoutes.instance.confirmScreen);
  }

  //----------Get sub summary----------
  Rxn<UserSummaryData> subSummaryList = Rxn<UserSummaryData>();
  Future<void> getSubSummary() async {
    final response = await _getRepository.getSubscriptionSummary();
    if (response != null) {
      subSummaryList.value = response;
    } else {
      AppPrint.appError("No Sub Summary Found");
    }
  }

  bool isPlanClaimed(num? price, String? value, int index) {
    final totalSubscriptions = profileValue.value?.totalSubscriptions;

    // 👉 NEW CONDITION (FIRST ITEM ONLY)
    if (totalSubscriptions != null && totalSubscriptions != 0 && index == 0) {
      return false;
    }

    // 👉 Free plan check (existing)
    if (profileValue.value?.hasUsedFreePlan == true) {
      if (price == 0) {
        return false;
      }
    }

    // 👉 Existing logic (unchanged)
    if (value1 == 1) {
      var titles = subSummaryList.value?.subscriptionTitles;

      if (titles != null && titles.isNotEmpty) {
        if (titles.last == value) {
          return false;
        }
      }
    }

    return true;
  }

  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      duration: const Duration(seconds: 3),
    );
  }

  /// Refresh user profile data after successful payment
  Future<void> _refreshUserProfile({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      final profileData = await _getRepository.getProfile();
      if (profileData != null) {
        profileValue.value = profileData;
        AppPrint.appLog('✅ Profile refreshed successfully');
        // The profile data is already handled by the repository
        // You may want to update local storage or notify other controllers here
      }
    } catch (e) {
      AppPrint.appError(e, title: 'Error refreshing profile');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  @override
  void onClose() {
    webViewController = null;
    super.onClose();
  }
}
