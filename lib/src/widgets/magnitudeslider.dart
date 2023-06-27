import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:walk/src/constants/bt_constants.dart';
import 'package:walk/src/controllers/device_controller.dart';

import '../constants/app_color.dart';

Widget magSlider(bool isClient, DeviceController controller) {
  return SizedBox(
    width: 180,
    child: Slider(
        //MAGNITUDE SLIDER
        value: isClient ? controller.magCValue : controller.magSValue,
        min: 0,
        max: 4,
        divisions: 4,
        label: controller.magSValue.toString(),
        thumbColor: AppColor.purpleColor,
        onChanged: (value) {
          HapticFeedback.lightImpact();
          isClient
              ? controller.setmagCValue(value)
              : controller.setmagSValue(value);
        },
        onChangeEnd: (value) async {
          String command = "";
          command = isClient ? "${MAG} c ${value}" : "${MAG} s ${value}";
          await controller.sendToDevice(command, WRITECHARACTERISTICS);
        }),
  );
}
