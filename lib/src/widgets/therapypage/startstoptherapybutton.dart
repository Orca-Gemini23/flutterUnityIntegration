// ignore_for_file: use_build_context_synchronously, unused_import, must_be_immutable

import "dart:async";
import "dart:math";
import "dart:developer" as dev;
import "package:awesome_dialog/awesome_dialog.dart";
import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:provider/provider.dart";
import "package:rive/rive.dart";
import "package:walk/src/constants/app_color.dart";
import "package:walk/src/constants/bt_constants.dart";
import "package:walk/src/controllers/animation_controller.dart";
import "package:walk/src/controllers/device_controller.dart";
import "package:walk/src/controllers/game_controller.dart";
import "package:walk/src/utils/firebasehelper.dart/firebasedb.dart";
import "package:walk/src/widgets/dialog.dart";

class AnimationControlButton extends StatefulWidget {
  AnimationControlButton({
    super.key,
    required this.animationStateController,
    required this.leftballInput,
    required this.rightballInput,
    required this.sendLeftBall,
    required this.sendRightBall,
  });

  StateMachineController? animationStateController;
  SMIInput<double>? leftballInput;
  SMIInput<double>? rightballInput;
  SMIInput<bool>? sendRightBall;
  SMIInput<bool>? sendLeftBall;

  @override
  State<AnimationControlButton> createState() => _AnimationControlButtonState();
}

class _AnimationControlButtonState extends State<AnimationControlButton> {
  StreamSubscription<List<int>>? animationValues;
  Timer? ballPeriodicTimer;

  Future<void> disposeEssentials() async {
    ballPeriodicTimer == null ? null : ballPeriodicTimer!.cancel();
    animationValues == null ? null : await animationValues!.cancel();
  }

  @override
  void dispose() {
    ballPeriodicTimer?.cancel();
    animationValues?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<DeviceController, GameController,
            AnimationValuesController>(
        builder: (context, deviceController, gameController,
            animationValuesController, child) {
      return ElevatedButton(
        onPressed: () async {
          onPressed(
              gameController, deviceController, animationValuesController);
        },
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.maxFinite, 80.h),
          backgroundColor: gameController.gameStatus == true
              ? AppColor.batteryindicatorred
              : AppColor.batteryindicatorgreen,
          shadowColor: gameController.gameStatus == true
              ? AppColor.batteryindicatorred.withOpacity(.4)
              : AppColor.batteryindicatorgreen.withOpacity(.4),
        ),
        child: gameController.gameStatus == true
            ? Text(
                "${gameController.secondsPlayed} seconds",
                style: TextStyle(color: AppColor.whiteColor, fontSize: 18.sp),
              ) ////Display a timer if the device
            : Text(
                "Start Game",
                style: TextStyle(color: AppColor.whiteColor, fontSize: 18.sp),
              ),
      );
    });
  }

  void onPressed(
      GameController gameController,
      DeviceController deviceController,
      AnimationValuesController animationValuesController) async {
    // testBallFalling();

    //check if the game is running or not
    if (gameController.gameStatus == true) {
      //// stop the game and handle upload to cloud
      gameController.stopTimer();
      await animationValues!.cancel();
      gameController.changeGameStatus(false);
      ballPeriodicTimer == null ? null : ballPeriodicTimer!.cancel();

      if (gameController.secondsPlayed > 10) {
        CustomDialogs.showScoreUplodingDialog(context);

        bool result = await FirebaseDB.uploadUserScore(
          score: gameController.scores,
          playedOn: DateTime.now(),
          secondsPlayedFor: gameController.secondsPlayed,
        );
        if (result) {
          Fluttertoast.showToast(msg: "Data uploaded");
          Navigator.of(context, rootNavigator: true).pop();
          gameController.resetTimer();
          gameController.resetGameScore();
        } else {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }
    } else {
      gameController.startTimer();
      handleGame(deviceController, animationValuesController, gameController);
      gameController.changeGameStatus(true);
    }
  }

  void handleGame(
      DeviceController deviceController,
      AnimationValuesController animationValuesController,
      GameController gameController) {
    gameController.resetGameScore();
    animationValues = deviceController.startStream();

    ballPeriodicTimer = Timer.periodic(
      const Duration(seconds: 6),
      (timer) async {
        int ball = selectRandomBall();
        gameController.changeIncremented(false);

        if (ball == 0) {
          Fluttertoast.showToast(msg: "Get ready Right Ball is coming !!!!");
          widget.animationStateController!
              .setInputValue(widget.sendRightBall!.id, true);
          int rightBallValue = 0;

          while (true) {
            if (deviceController.rightAngleValue > 30 &&
                rightBallValue >= 35 &&
                rightBallValue <= 45) {
              if (!gameController.isIncremented) {
                gameController.incrementScore();
                gameController.changeIncremented(true);
              }
            }
            if (rightBallValue > 100) {
              widget.animationStateController!
                  .setInputValue(widget.rightballInput!.id, 0);
              widget.animationStateController!
                  .setInputValue(widget.sendRightBall!.id, false);
              break;
            } else {
              widget.animationStateController!.setInputValue(
                widget.rightballInput!.id,
                rightBallValue.toDouble(),
              );
              rightBallValue == 25
                  ? await deviceController.sendToDevice(
                      "beepc 4;", WRITECHARACTERISTICS)
                  : null;

              await Future.delayed(
                const Duration(milliseconds: 30),
              );
              rightBallValue++;
            }
          }
        } else {
          Fluttertoast.showToast(msg: "Get ready Left Ball is coming !!!!");
          widget.animationStateController!
              .setInputValue(widget.sendLeftBall!.id, true);
          int leftBallValue = 0;

          while (true) {
            if (deviceController.leftAngleValue > 30 &&
                leftBallValue >= 35 &&
                leftBallValue <= 45) {
              if (!gameController.isIncremented) {
                gameController.incrementScore();
                gameController.changeIncremented(true);
              }
            }
            if (leftBallValue > 100) {
              widget.animationStateController!
                  .setInputValue(widget.leftballInput!.id, 0);
              widget.animationStateController!
                  .setInputValue(widget.sendLeftBall!.id, false);
              break;
            } else {
              widget.animationStateController!.setInputValue(
                widget.leftballInput!.id,
                leftBallValue.toDouble(),
              );
              leftBallValue == 25
                  ? await deviceController.sendToDevice(
                      "beeps 4;", WRITECHARACTERISTICS)
                  : null;

              await Future.delayed(const Duration(milliseconds: 30));
              leftBallValue++;
            }
          }
        }
      },
    );
  }

  int selectRandomBall() {
    return Random().nextInt(2);
  }

  void testGame() {
    var ballTimer = Timer.periodic(const Duration(seconds: 6), (timer) async {
      if (true) {
        for (int i = 0; i <= 100; i++) {
          await Future.delayed(const Duration(milliseconds: 20));
          widget.leftballInput!.change(i.toDouble());
        }
      }
    });
  }
}
