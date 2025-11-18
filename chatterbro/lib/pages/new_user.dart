import 'package:chatterbro/components/button.dart';
import 'package:chatterbro/components/text_field.dart';
import 'package:flutter/material.dart';

class NewUser extends StatelessWidget{
  final TextEditingController control1;
  final TextEditingController control2;
  const NewUser({
    super.key,
    required this.control1,
    required this.control2
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New contact"),
      ),
      body:Column(
        children: [
          Row(
            children: [
              Icon(Icons.person),
              SizedBox(width: 20),
              TextFields(
                textheight: 50,
                textwidth: 300,
                visibility: false,
                control: control1,
                myhinttext: "UserName",
                eyebutton: false,
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.email),
              SizedBox(width: 20),
              TextFields(
                textheight: 50,
                textwidth: 300,
                visibility: false,
                control: control2,
                myhinttext: "Email",
                eyebutton: false,
              ),
            ],
          ),
          SizedBox(height: 40),
          MyButton(
            wid: 300, 
            len: 40, 
            text: "Save", 
            buttoncolor: const Color.fromARGB(255, 0, 255, 8), 
            ontap: (){Navigator.pop(context, 
            {
              'username': control1.text.trim(),
              'email': control2.text.trim(),
            });
            }
          )
        ],
      )
    );
  }
}