// ignore_for_file: unnecessary_string_interpolations

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import 'package:walk/src/constants/app_color.dart';
import 'package:walk/src/constants/app_strings.dart';
import 'package:walk/src/controllers/auth_controller.dart';

import 'package:walk/src/utils/custom_navigation.dart';
import 'package:walk/src/utils/screen_context.dart';

import 'package:walk/src/views/revisedhome/newhomepage.dart';

class OTPPage extends StatefulWidget {
  const OTPPage({super.key, required this.email});
  final String email;
  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final TextEditingController _otpController = TextEditingController();
  final RoundedLoadingButtonController _buttonController =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(
                  top: 50,
                  child: Image(
                    height: 120,
                    width: 120,
                    image: AssetImage(
                      "assets/images/walk.png",
                    ),
                  )),
              Container(
                height: Screen.height(context: context),
                width: Screen.width(context: context),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: Screen.height(context: context) * 0.32,
                      ),
                      const Text(
                        '${AppString.otpPage}',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: Screen.height(context: context) * 0.01,
                      ),
                      Text(
                        '${AppString.pleaseEnterOtp}\n${widget.email}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: Screen.height(context: context) * 0.05,
                      ),
                      Pinput(
                        length: 6,
                        controller: _otpController,
                      ),
                      SizedBox(
                        height: Screen.height(context: context) * 0.1,
                      ),
                      Consumer<AuthController>(
                          builder: (context, authController, child) {
                        return RoundedLoadingButton(
                          controller: _buttonController,
                          animateOnTap: false,
                          color: AppColor.greenDarkColor,
                          successColor: AppColor.greenDarkColor,
                          onPressed: () async {
                            if (_otpController.text.length == 6) {
                              bool otpVerified = await authController.verifyOtp(
                                  widget.email, _otpController.text);
                              if (otpVerified) {
                                _buttonController.success();
                                // bool result =
                                //     await PreferenceController.getboolData(
                                //         showCaseKey);
                                // bool unboxStatus =
                                //     await PreferenceController.getboolData(
                                //         "isUnboxingDone");

                                // ignore: use_build_context_synchronously
                                Go.pushAndRemoveUntil(
                                  context: context,
                                  pushReplacement: const RevisedHomePage(),
                                );
                              } else {
                                _buttonController.error();
                                Timer(const Duration(seconds: 2), () {
                                  _buttonController.reset();
                                });
                              }
                            }
                          },
                          child: const Text(
                            AppString.verifyOtp,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        );
                      }),
                      SizedBox(
                        height: Screen.height(context: context) * 0.1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            AppString.otpNotReceived,
                            style: TextStyle(
                                color: Colors.black45,
                                fontSize: 18,
                                fontWeight: FontWeight.w300),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              AppString.resendOtp,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
