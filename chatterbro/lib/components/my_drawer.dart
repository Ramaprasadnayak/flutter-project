import 'package:chatterbro/components/themes.dart';
import 'package:chatterbro/pages/login_page.dart';
import 'package:chatterbro/pages/settingpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class MyDrawer extends StatelessWidget{
  final bool isDark;
  MyDrawer({super.key,required this.isDark});
  final theme = ThemeConfig();

  @override
  Widget build(BuildContext context) {
    Future<void> logout() async {
      await FirebaseAuth.instance.signOut();
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
    return Drawer(
      backgroundColor:isDark? Color.fromARGB(255, 66, 29, 90) :Color.fromARGB(255, 240, 245, 250),
      child: Column(
        children: [
          SizedBox(height: 90),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: ListTile(
              title: Text("Home",style: TextStyle(color:isDark? Color.fromARGB(255, 255, 255, 255) :Color.fromARGB(255, 0, 0, 0))),
              leading: Icon(Icons.home,color: isDark? Color.fromARGB(255, 255, 255, 255) :Color.fromARGB(255, 97, 97, 97)),
              onTap: (){
                Navigator.pop(context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: ListTile(
              title: Text("settings",style: TextStyle(color:isDark? Color.fromARGB(255, 255, 255, 255) :Color.fromARGB(255, 0, 0, 0))),
              leading: Icon(Icons.settings,color:isDark? Color.fromARGB(255, 255, 255, 255) :Color.fromARGB(255, 97, 97, 97)),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>SettingsPage(),));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: ListTile(
              title: Text("log out",style: TextStyle(color:isDark? Color.fromARGB(255, 255, 255, 255) :Color.fromARGB(255, 0, 0, 0))),
              leading: Icon(Icons.logout,color:isDark? Color.fromARGB(255, 255, 255, 255) :Color.fromARGB(255, 97, 97, 97)),
              onTap: (){
                logout();
              },
            ),
          )
        ],
      ),
    );
  }
}

// Future<void> logout() async {
//       await FirebaseAuth.instance.signOut();
//       Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
//     }