import 'package:chatterbro/components/background_color.dart';
import 'package:chatterbro/components/button.dart';
import 'package:chatterbro/components/text_field.dart';
import 'package:chatterbro/home_page.dart';
import 'package:chatterbro/pages/register_page.dart';
import 'package:chatterbro/services/auth_services.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>{
  TextEditingController email =TextEditingController();
  TextEditingController password =TextEditingController();

  void loginlogic(BuildContext context) async {
    final authService=AuthServices();
    try{
      await authService.signInWithEmailPassword(email.text.trim(), password.text.trim());
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => Homepage(isDark: false)),
    );
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
      ),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login Page"),backgroundColor: Color.fromARGB(255, 240, 245, 250),automaticallyImplyLeading: false),
      body: BackgroundColor(
        color1: Color.fromARGB(255, 255, 255, 255),
        color2: Color(0xFF4ADEDE),
        mychild: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 320,
              height:350,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(color: Colors.black12)
                ]
              ),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Text("Welcome back bro, please sign in",style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold)),
                    SizedBox(height: 25),
                    TextFields(
                      textwidth: 260,
                      textheight: 50,
                      visibility: false, 
                      control: email, 
                      myhinttext: "enter your email.",
                      eyebutton: false
                    ),
                    SizedBox(height: 10),
                    TextFields(
                      textwidth: 260,
                      textheight: 50,
                      visibility: true,
                      control: password, 
                      myhinttext: "Enter your password.",
                      eyebutton: true
                    ),
                    SizedBox(height: 20),
                    MyButton(
                      wid: 250, 
                      len: 50,
                      text:"login", 
                      buttoncolor: Colors.pinkAccent,
                      ontap:()=>loginlogic(context)
                    ),
                    SizedBox(height: 7),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("don't have a account "),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context)=>RegisterPage()
                            )
                          ),
                          child: Text("click here.",style:TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        )
      )
    );
  }
}