import 'package:chatterbro/components/background_color.dart';
import 'package:chatterbro/components/my_drawer.dart';
import 'package:chatterbro/components/themes.dart';
import 'package:chatterbro/components/user_tile.dart';
import 'package:chatterbro/pages/chatpage.dart';
import 'package:chatterbro/pages/login_page.dart';
import 'package:chatterbro/pages/new_user.dart';
import 'package:chatterbro/services/auth_services.dart';
import 'package:chatterbro/services/chat_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  final bool isDark;
  Homepage({super.key,required this.isDark});
  //include the instances 
  final ChatServices _chatServices = ChatServices();
  final AuthServices _authServices = AuthServices();
  final theme = ThemeConfig();

  @override
  Widget build(BuildContext context) {
    
    //logout logic in the iconbutton logout button
    Future<void> logout() async {
      await FirebaseAuth.instance.signOut();
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ChatterBro",
          style: TextStyle(color: theme.isDark? theme.fcolor1 :theme.fcolor2),
        ),
        backgroundColor: theme.isDark? Color.fromARGB(255, 66, 29, 90) :Color.fromARGB(255, 240, 245, 250),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
        actions: [IconButton(onPressed: logout, icon: Icon(Icons.logout))],
      ),

      drawer: MyDrawer(isDark: isDark),
      body: BackgroundColor(
        color1: theme.isDark? theme.color1 :theme.color3,
        color2: theme.isDark? theme.color2 :theme.color4,
        mychild: buildUserList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleAddChat(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildUserList() {
    //lists all the registered users in  homepage
    return StreamBuilder(
      stream: _chatServices.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting){
          return const Text("Loading...");
        }
        return ListView(
          //snapshot.data has the current user info
          children: snapshot.data!.map<Widget>((userData) => _buildUserListItem(userData, context)).toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    //if the user exists or not
    if (userData["email"] != _authServices.getCurrentuser()!.email) {
      return UserTile(
        isDark:isDark,
        text: userData["email"],
        onTap: () {
          //on pressing the page will go to the chat page
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Chatpage(
                    isDark:isDark,
                    receiverEmail: userData["email"],
                        receiverID: userData["uid"],
                      )
              )
          );
        },
        onDelete: () async {
    try {
      await _chatServices.deleteChatRoom(userData["uid"]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Chat deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting chat: $e")),
      );
    }});
    } else {
      return Container();
    }
  }
void _handleAddChat(BuildContext context) async {
  TextEditingController emailController = TextEditingController();
  TextEditingController userController = TextEditingController();

  final data = await Navigator.push(context, 
  MaterialPageRoute(
    builder: (context)=>NewUser(
      control1: userController, 
      control2: emailController
  )));
  if (data == null || data.isEmpty) return;

  try {
    await _authServices.addChatByEmail(context, data["username"],data["email"]);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}
}
