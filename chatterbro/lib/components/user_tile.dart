import 'package:chatterbro/components/themes.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget{
  final String text;
  final bool isDark;
  // final String username;
  final void Function()? onTap;
  final void Function()? onDelete;


  UserTile({
    super.key,
    // required this.username,
    required this.text,
    required this.onTap,
    required this.onDelete,
    required this.isDark
  });
   final theme = ThemeConfig();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark? Color.fromARGB(255, 235, 239, 242) :const Color.fromARGB(255, 255,255,255),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(vertical: 5,horizontal: 25),
        padding: EdgeInsets.all(20),
        child: Row(
  children: [
    Icon(Icons.person),
    SizedBox(width: 20),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("username", style: TextStyle(color: Colors.black, fontSize: 20)),
          Text(text),
        ],
      ),
    ),
    IconButton(
      icon: Icon(Icons.delete, color: Colors.red),
      onPressed: onDelete,
    ),
  ],
),
      ),
    );
  }
}