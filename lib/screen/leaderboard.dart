import 'package:chess_game/colors.dart';
import 'package:chess_game/screen/homepage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLeaderboardData();
  }

  Future<void> loadLeaderboardData() async {
    try {
      final response = await http.get(Uri.parse('https://schmidivan.com/Esakki/ChessGame/leaderboard'));
      if (response.statusCode == 200) {
        dynamic jsonData = jsonDecode(response.body);
        if (jsonData['success'] != null && jsonData['success']) {
          List<dynamic> data = jsonData['data'];
          setState(() {
            users = data.map((user) => User(
              username: user['name'] ?? 'Unknown', // Handle null username
              points: user['points'] ?? 0, // Handle null points
              imagepath: 'https://schmidivan.com/Esakki/ChessGame/${user['image_path']}' ?? "", // Handle null image URL
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: isLoading
          ? Indicator()
      //Center(child: CircularProgressIndicator())
          : Container(
        height: screenHeight,
        width: screenWidth,
        child: Column(
          children: [
            Container(
              height: screenHeight / 15,
              width: screenWidth,
              color: color.navy1,
              child: Row(
                children: [
                  Text('Rank' , style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 15),),
                  SizedBox(width: screenWidth/5,),
                  Text('Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 15),),
                  SizedBox(width: screenWidth/2,),
                  Text('Coins', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 15),),
                ],
              ),
            ),
            Expanded(
              // child: Padding(
              //   padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: screenHeight - (screenHeight / 15)),
                    child: Column(
                      children: users.asMap().entries.map((entry) {
                        int index = entry.key;
                        User user = entry.value;
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 5.0,
                          color: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16.0),
                           // tileColor: Colors.red,
                            leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                Text(
                                (index + 1).toString(),
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 15),
                          ),
                          SizedBox(width: screenWidth/15,),
                          CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              backgroundImage: user.imagepath.isNotEmpty
                                  ? NetworkImage(user.imagepath)
                                  : null,
                              child: user.imagepath.isEmpty
                                  ? Text(
                                (index + 1).toString(),
                                style: TextStyle(color: Colors.black),
                              )
                                  : null,
                            ),]),
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
              ),
       //     ),
          ],
        ),
      ),
    );
  }
}

class User {
  final String username;
  final int points;
  final String imagepath;

  User({required this.username, required this.points, required this.imagepath});
}
