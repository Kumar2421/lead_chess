import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<User> users = [];
  bool isLoading = true;
  late Map<String, dynamic> userData = {};
  @override
  void initState() {
    super.initState();
    loadLeaderboardData();
  }

  Future<void> loadLeaderboardData() async {
    try {
      final response = await http.get(Uri.parse('https://schmidivan.com/senthil/_ChessGame/leaderboard'));
      if (response.statusCode == 200) {
        dynamic jsonData = jsonDecode(response.body);
        if (jsonData['success'] != null && jsonData['success']) {
          List<dynamic> data = jsonData['data'];
          setState(() {
            users = data.map((user) => User(
              username: user['name'] ?? 'Unknown', // Handle null username
              points: user['points'] ?? 0, // Handle null points
              imagepath: user['https://schmidivan.com/senthil/_ChessGame/cheque/profile_image_${userData['user_id'] ?? ''}.jpg'] ??"", // Handle null image URL
            )).toList();
            users.sort((a, b) => b.points.compareTo(a.points)); // Sort by points in descending order
            isLoading = false;
          });
        } else {
          throw Exception('Failed to fetch user data: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to fetch user data. HTTP status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading leaderboard data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView( // Enable scrolling
          child: Column(
            children: users.map((user) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    backgroundImage: user.imagepath.isNotEmpty
                        ? NetworkImage(user.imagepath) // Display user image
                        : null,
                    child: user.imagepath.isEmpty
                        ? Text(
                      users.indexOf(user).toString(),
                      style: TextStyle(color: Colors.white),
                    )
                        : null,
                  ),
                  title: Text(
                    user.username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    user.points.toString(),
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class User {
  final String username;
  final int points;
  final String imagepath; // New field for the image URL

  User({required this.username, required this.points, required this.imagepath});
}



