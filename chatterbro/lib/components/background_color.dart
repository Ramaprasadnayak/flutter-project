import 'package:flutter/material.dart';

class BackgroundColor extends StatelessWidget{
  final Widget mychild;
  final Color color1,color2;
  const BackgroundColor({super.key,required this.mychild,required this.color1,required this.color2});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1,color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight
          )
        ),
        child:SafeArea(child: mychild)
      );
  }
}