import 'package:flutter/material.dart';

class TextFields extends StatefulWidget {
  final bool visibility;
  final TextEditingController control;
  final String myhinttext;
  final double textwidth, textheight;
  final bool eyebutton;

  const TextFields({
    super.key,
    required this.textheight,
    required this.textwidth,
    required this.visibility,
    required this.control,
    required this.myhinttext,
    required this.eyebutton
  });

  @override
  State<TextFields> createState() => _TextFieldState();
}

class _TextFieldState extends State<TextFields> {
  late bool _isVisible;

  @override
  void initState() {
    super.initState();
    _isVisible = widget.visibility; 
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.textwidth,
      height: widget.textheight,
      child: TextField(
        controller: widget.control,
        obscureText: _isVisible,
        decoration: InputDecoration(
          hintText: widget.myhinttext,
          hintStyle: const TextStyle(color: Colors.grey),
          enabledBorder: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(),
          suffixIcon: widget.eyebutton?IconButton(
            icon: Icon(
              _isVisible ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _isVisible = !_isVisible;
              });
            },
          ):null
        ),
      ),
    );
  }
}
