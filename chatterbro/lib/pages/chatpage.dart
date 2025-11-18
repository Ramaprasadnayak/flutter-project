import 'package:chatterbro/components/background_color.dart';
import 'package:chatterbro/components/text_field.dart';
import 'package:chatterbro/services/auth_services.dart';
import 'package:chatterbro/services/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Chatpage extends StatelessWidget {
  final String receiverEmail;  
  final String receiverID;
  final bool isDark;

  Chatpage({
    super.key,
    required this.isDark,
    required this.receiverEmail,
    required this.receiverID,
  });
  final TextEditingController _messageCon = TextEditingController();
  final ChatServices _chatServices = ChatServices();
  final AuthServices _authServices = AuthServices();
  Future<void> sendMessage(BuildContext context) async {
    if (_messageCon.text.trim().isNotEmpty) {
      try {
        await _chatServices.sendMessage(receiverID, _messageCon.text.trim());
        _messageCon.clear();  // Clear only if successful
      } catch (e) {
        // Show error in UI (e.g., SnackBar)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send message: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = _authServices.getCurrentuser()!.uid;  

    return Scaffold(
      appBar: AppBar(
        title: Text(receiverEmail),
        actions: [
  PopupMenuButton<String>(
    icon: Icon(Icons.more_vert), // 3-dot icon
    onSelected: (String value) async { // make this async
      if (value == 'Clear Chat') {
        final currentUserId = _authServices.getCurrentuser()!.uid;
        await _chatServices.clearChat(currentUserId, receiverID);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Chat cleared!"))
        );
      } else if (value == 'Block User') {
        print('Block User clicked');
      }
    },
    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
      const PopupMenuItem<String>(
        value: 'Clear Chat',
        child: Text('Clear Chat'),
      ),
      const PopupMenuItem<String>(
        value: 'Block User',
        child: Text('Block User'),
      ),
    ],
  ),
],
        backgroundColor:isDark? Color.fromARGB(255, 15, 15, 104): const Color.fromARGB(255, 255, 255, 255),  
        foregroundColor: isDark? Color.fromARGB(255, 247, 247, 247): const Color.fromARGB(255, 0, 0, 0),
      ),
      body: BackgroundColor(
        color1: isDark? Color.fromARGB(255, 15, 15, 104): const Color.fromARGB(255, 255, 255, 255),
        color2: isDark? Color.fromARGB(255, 29, 85, 141): Color.fromARGB(255, 74, 108, 140) ,
        mychild:
          Column(
            children: [
              Expanded(
                child: _buildMessageList(currentUserId),
              ),
              _buildUserInput(context),
            ],
          ),
      ),
    );
  }
  Widget _buildMessageList(String currentUserId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatServices.getMessages(currentUserId, receiverID),  
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No messages yet. Start the conversation!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        return ListView(
          reverse: true, 
          shrinkWrap: true,
          children: snapshot.data!.docs.map((doc) => _buildMessageItem(doc, currentUserId)).toList(),
        );
      },
    );
  }
  Widget _buildMessageItem(DocumentSnapshot doc, String currentUserId) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final bool isCurrentUser = data['senderId'] == currentUserId;
    final Timestamp? timestamp = data['timestamp'];
final String timeStr = timestamp != null 
    ? '${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}' 
    : '';


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey[300],
              child: Text(data['senderEmail']?[0] ?? '?'),  
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isCurrentUser ? Color(0xFF302B63) : Colors.grey[200],  // Theme colors
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Column(
                crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    data["message"],
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  if (timeStr.isNotEmpty)
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: isCurrentUser ? Colors.white70 : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 12,
              backgroundColor: Color(0xFF0F0C29),
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildUserInput(context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFields(
              textheight:50, 
              textwidth:260, 
              visibility: false, 
              control: _messageCon, 
              myhinttext: "Type a message",
              eyebutton: false,
            )
          ),
          SizedBox(width: 8),
          IconButton(
              onPressed: () async {
                await sendMessage(context);
            },
            icon: const Icon(Icons.arrow_upward),
            color: Color.fromARGB(255, 0, 0, 0),  
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        ],
      ),
    );
  }
}