import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import '../AllScreens/loginScreen.dart';

class AppDrawer extends StatelessWidget {
  final LocalStorage storage = new LocalStorage('localstorage_app');

  String name="",email="",imgUrl="";
  AppDrawer({required this.name,required this.email,required this.imgUrl}) : super();


  void logout(context) async {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.confirm,
      text: 'Do you want to Logout?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      confirmBtnColor: Colors.green,
      onConfirmBtnTap: () async {
        await Future.delayed(Duration(milliseconds: 1000));
        Navigator.pop(context);
        await storage.clear().then((value) => {
          Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false)
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildDrawerHeader(context),
            buildDrawerItems(context),
          ],
        ),
      )
    );
  }


  Widget buildDrawerHeader(BuildContext context) => Container(
    color: Colors.green,
    padding: EdgeInsets.only(
        top: 24 + MediaQuery.of(context).padding.top, bottom: 24),
    child: Column(
      children: [
        CircleAvatar(
          radius: 70,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 65,
            backgroundColor: Colors.greenAccent,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(imgUrl),
            ),
          ),
        ),
        SizedBox(height: 12),
        Text(
          name,
          style: TextStyle(fontSize: 28.0, color: Colors.white),
        ),
        Text(
          email,
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        )
      ],
    ),
  );

  Widget buildDrawerItems(BuildContext context) => Container(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        runSpacing: 16,
        children: [
          ListTile(
            leading: const Icon(Icons.account_circle_rounded),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, "ProfileScreen.idScreen", (route) => true);
              Scaffold.of(context).openEndDrawer();
            },
          ),
          ListTile(
            leading: const Icon(Icons.app_registration),
            title: const Text('Accomadation'),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, "Accomadation.idScreen", (route) => true);
              Scaffold.of(context).openEndDrawer();
            },
          ),
          if(storage.getItem('userType').toString()=="admin") ...[
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin Dashboard'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, "AdminDashboard.idScreen", (route) => true);
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Calender'),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, "CalenderScreen.idScreen", (route) => true);
              Scaffold.of(context).openEndDrawer();
            },
          ),
          const Divider(color: Colors.black54),
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: const Text('Logout'),
            onTap: () {
              logout(context);
            },
          ),
        ],
      ));
}
