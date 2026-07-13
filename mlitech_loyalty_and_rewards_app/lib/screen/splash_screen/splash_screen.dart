import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loyalty_customer/const/app_color.dart';
import 'package:loyalty_customer/const/assets_icons_path.dart';
import 'package:loyalty_customer/screen/splash_screen/controller/splash_controller.dart';
import 'package:loyalty_customer/utils/app_size.dart';
import 'package:loyalty_customer/widget/app_image/app_image.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    AppSize.size = size;
    return GetBuilder<SplashController>(
      init: SplashController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColor.button5Light,
          body: Obx(
            () => Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                child: AnimatedOpacity(
                  duration: Duration(seconds: 2),
                  opacity: controller.animation2.value,
                  child: AnimatedScale(
                    scale: controller.animation.value,
                    duration: Duration(seconds: 2),
                    curve: Curves.easeOutExpo,
                    child: AppImage(
                      path: AssetsPath.logo,
                     
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
