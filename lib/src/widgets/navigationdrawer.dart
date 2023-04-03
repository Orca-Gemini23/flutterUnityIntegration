import 'package:flutter/material.dart';
import 'package:walk/src/constants/constants.dart';
import 'package:walk/src/utils/screen_context.dart';

Drawer navigationDrawer(BuildContext context) {
  return Drawer(
    // backgroundColor: Color(DRAWERCOLOR),
    semanticLabel: "drawer",
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
    elevation: 30,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          height: Screen.height(context: context) * 0.25,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              CircleAvatar(),
              SizedBox(
                height: 20,
              ),
              Text(
                "Kira Sardeshpande",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        drawerItem(),
      ],
    ),
  );
}

Widget drawerItem() {
  List<IconData> _drawerIcon = [
    Icons.home,
    Icons.person,
    Icons.tune,
    Icons.group,
    Icons.email,
    Icons.logout_sharp,
  ];
  List<String> _drawerTileName = [
    'Home',
    'Profile',
    'Device Control',
    'About Us',
    'Contact Us',
    'Log Out',
  ];
  return ListView.builder(
    shrinkWrap: true,
    itemBuilder: (context, index) {
      return ListTile(
        leading: Icon(_drawerIcon[index]),
        title: Text(
          _drawerTileName[index],
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
        onTap: () {},
      );
    },
    itemCount: _drawerTileName.length,
  );
}
