import 'package:chatterbro/components/background_color.dart';
import 'package:chatterbro/components/themes.dart';
import 'package:chatterbro/home_page.dart'; 
import 'package:flutter/material.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget { 
  const SettingsPage({super.key}); 
  @override State<SettingsPage> createState() => _SettingsPageState(); 
} 
  
enum AppTheme { light, dark }
class _SettingsPageState extends State<SettingsPage> {
  AppTheme? _selectedTheme = AppTheme.light;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserEmail = currentUser?.email ?? "No Email";

    // Map theme to colors
    final theme = ThemeConfig();

    return Scaffold(
      appBar: AppBar(
        title: Text(currentUserEmail,style: TextStyle(color: theme.isDark? Color.fromARGB(255, 255, 255, 255):const Color.fromARGB(255, 0, 0, 0))),
        backgroundColor:theme.isDark? Color.fromARGB(255, 66, 29, 90):Color.fromARGB(255, 240, 245, 250),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: theme.isDark? Color.fromARGB(255, 255, 255, 255):const Color.fromARGB(255, 0, 0, 0)), // your icon
          onPressed: () {
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => Homepage(isDark: theme.isDark)));}
        )
      ),
      body: BackgroundColor(
        color1: theme.isDark? theme.color1 :theme.color3,
        color2: theme.isDark? theme.color1 :theme.color3,
        mychild: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Section
              Text(
                "Themes :",
                style: TextStyle(
                  color: theme.isDark? theme.fcolor1 :theme.fcolor2,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              RadioListTile<AppTheme>(
                title: Text("Light",style: TextStyle(color: theme.isDark? theme.fcolor1 :theme.fcolor2)),
                value: AppTheme.light,
                groupValue: _selectedTheme,
                onChanged: (AppTheme? value) {
                  setState(() {
                    _selectedTheme = AppTheme.light;
                    theme.isDark=false;
                  });
                },
              ),
              RadioListTile<AppTheme>(
                title: Text("Dark",style: TextStyle(color: theme.isDark? theme.fcolor1 :theme.fcolor2)),
                value: AppTheme.dark,
                groupValue: _selectedTheme,
                onChanged: (AppTheme? value) {
                  setState(() {                      
                    _selectedTheme = AppTheme.dark;
                    theme.isDark=true;
                  });
                },
              ),
              SizedBox(height: 40),

              // Delete Account Section
              Text(
                "Delete account :",
                style: TextStyle(
                  color: theme.isDark? theme.fcolor1 :theme.fcolor2,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => _showDeleteConfirmation(context),
                child: Text("Delete Account",style: TextStyle(color: theme.isDark? theme.fcolor1 :theme.fcolor2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Account?"),
        content: Text(
            "This action will permanently delete your account and all data. Are you sure you want to continue?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _deleteAccount(context);
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete(); // Deletes Firebase account
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Account deleted successfully."),
          ),
        );
        // Navigate to login page or exit app
        Navigator.of(context).pushReplacementNamed('/login'); // Adjust route
      }
    } on FirebaseAuthException catch (e) {
      // Some errors require recent login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.message}"),
        ),
      );
    }
  }
}