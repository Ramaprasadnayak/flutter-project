import 'package:flutter/material.dart';

class MyButton extends StatelessWidget{
  final double wid,len;
  final Color buttoncolor;
  final String text;
  final Function ontap;
  const MyButton({super.key,required this.wid,required this.len,required this.text,required this.buttoncolor,required this.ontap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:()=>ontap(),
      child: 
        Container(
          width: wid,
          height: len,
          decoration: BoxDecoration(
            color: buttoncolor,
            borderRadius: BorderRadius.circular(10)
          ),
          child: Center(
            child: Text(text),
          ),
        ),
    );
  }
}