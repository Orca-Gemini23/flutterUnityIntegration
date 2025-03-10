import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:walk/src/constants/app_color.dart';
import 'package:walk/src/server/api.dart';
import 'package:walk/src/utils/global_variables.dart';

class TodaysGoalBox extends StatefulWidget {
  const TodaysGoalBox({
    super.key,
    required this.goalBoxKey,
  });

  final GlobalKey goalBoxKey;

  @override
  State<TodaysGoalBox> createState() => _TodaysGoalBoxState();
}

class _TodaysGoalBoxState extends State<TodaysGoalBox> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: widget.goalBoxKey,
      onTap: () {
        // Go.to(
        //   context: context,
        //   push: const StepGoalPage(),
        // );
      },
      child: Container(
        ////Todays's goal Container

        padding: const EdgeInsets.only(
          top: 20,
          bottom: 20,
          left: 10,
          right: 10,
        ),
        width: double.maxFinite,
        height: 158.h,
        decoration: BoxDecoration(
          color: AppColor.lightbluegrey,
          boxShadow: const [
            BoxShadow(
              blurRadius: 2,
              spreadRadius: 2,
              color: AppColor.greyLight,
            )
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Positioned(
              child: Image(
                fit: BoxFit.contain,
                width: 143.w,
                height: 105.h,
                image: const AssetImage(
                  "assets/images/re1.png",
                ),
              ),
            ),
            Positioned(
              right: DeviceSize.isTablet ? 125 : 25,
              top: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Goal",
                    style: TextStyle(
                      color: AppColor.greenDarkColor,
                      fontFamily: 'Helvetica',
                      fontSize: 20.sp,
                      // letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Completed',
                          style: TextStyle(
                            color: AppColor.greenDarkColor,
                            fontFamily: 'Helvetica',
                            fontSize: 20.sp,
                            // letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const WidgetSpan(
                          child: SizedBox(
                            width: 5,
                          ),
                        ),
                        WidgetSpan(
                          child: Icon(
                            Icons.verified,
                            color: AppColor.amberColor,
                            size: 20.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  FutureBuilder(
                      future: API.getScore(),
                      builder: ((context, snapshot) {
                        var gaitScore = snapshot.hasData
                            ? (snapshot.data as Map)["data"]['Gait Score']
                            : "";
                        var balanceScore = snapshot.hasData
                            ? (snapshot.data as Map)["data"]['Balance Score']
                            : "";

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Gait Score : $gaitScore",
                              style: TextStyle(
                                color: AppColor.greenDarkColor,
                                fontFamily: 'Helvetica',
                                fontSize: 16.h,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              "Balance Score : $balanceScore",
                              style: TextStyle(
                                color: AppColor.greenDarkColor,
                                fontSize: 16.h,
                                fontFamily: 'Helvetica',
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        );
                      }))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
