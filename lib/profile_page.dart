import 'dart:convert';
import 'dart:io';
import 'package:chess_game/screen/homepage.dart';
import 'package:chess_game/user/current_user.dart';
import 'package:chess_game/user/users.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // String? imagePath;
  final picker = ImagePicker();
  late Map<String, dynamic> userData = {};
  bool _isLoading = true;
  String? _profilePicturePath;
  Users currentUser = Get.find<CurrentUser>().users;
  final UserController userController = Get.find<UserController>();
  String? _userId;
  @override
  void initState() {
    super.initState();
    _startLoadingIndicator();
    loadUserData();
   fetchProfilePicturePath(currentUser.userId, currentUser.email);
   // loadProfilePicturePath(currentUser.userId);
   // getusers();
  }
  void _startLoadingIndicator(){
    Future.delayed(Duration(seconds: 1), (){
      setState(() {
        _isLoading = false;
      });
    });
}
  Future<List<Users>?> getusers() async {
    var client = http.Client();
    //var uri = Uri.parse('https://leadproduct.000webhostapp.com/chessApi/signup.php');
    var uri = Uri.parse('https://schmidivan.com/Esakki/ChessGame/signup');
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      String json = response.body;
      return welcomeFromJson(json);
    }
    return null;
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');
    if (userDataString != null) {
      setState(() {
        userData = jsonDecode(userDataString);
      });
    }
  }
  Future<String?> fetchUserId(String userId, String email) async {
    try {
      final response = await http.post(
        //Uri.parse('https://leadproduct.000webhostapp.com/chessApi/fetch_userid.php'),
        Uri.parse('https://schmidivan.com/Esakki/ChessGame/fetch_userid'),
        body: {
          'user_id': userId,
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('error');
        if (responseData.containsKey('userId')) {
          print('pass');
          return responseData['userId'].toString();
        } else if (responseData.containsKey('error')) {
          throw Exception(responseData['error']);
        } else {
          throw Exception('Unexpected response');
        }
      } else {
        throw Exception('Failed to fetch user ID: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user ID: $e');
      return null;
    }
  }
  Future<void> fetchProfilePicturePath(String userId, String email) async {
    try {
      final response = await http.post(
        //Uri.parse('https://leadproduct.000webhostapp.com/chessApi/fetch_profile_picture.php'),
        Uri.parse('https://schmidivan.com/Esakki/ChessGame/fetch_profile_picture'),
        body: {
          'user_id': userId,
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Check if the imagePath key exists in the response data
        if (responseData.containsKey('imagePath')) {
          final String imagePath = responseData['imagePath'];

          // Assuming imagePath contains the file name only, concatenate it with the base URL
         // const String baseUrl = 'https://leadproduct.000webhostapp.com/chessApi/';
          const String baseUrl = 'https://schmidivan.com/Esakki/ChessGame/';
          final String imageUrl = baseUrl + imagePath;

          setState(() {
            _userId = userId;
            _profilePicturePath = imageUrl; // Update _profilePicturePath with the complete URL
            userController.setProfilePicturePath(imageUrl);
          });
        } else {
          // Handle case where no image path is found
          setState(() {
            _userId = null;
            _profilePicturePath = null; // Set _profilePicturePath to null or a default image URL
            userController.setProfilePicturePath('');
          });
        }
      } else {
        throw Exception('Failed to fetch image data');
      }
    } catch (e) {
      print('Error fetching image: $e');
    }
  }
  void deleteProfileImage() async {
    try {
      Users currentUser = Get.find<CurrentUser>().users;
      var response = await http.post(
        Uri.parse('https://schmidivan.com/Esakki/ChessGame/delete_image'),
        body: {
          'user_id': currentUser.userId,
          'email': currentUser.email,
        },
      );

      if (response.statusCode == 200) {
        // Successfully deleted profile image
        print('Profile image deleted successfully');
        setState(() {
          _profilePicturePath = null;
        });
        // Remove the profile picture path from SharedPreferences
        userController.deleteProfilePicturePath();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove('profilePicturePath_${currentUser.userId}');
      } else {
        // Failed to delete profile image
        print('Failed to delete profile image');
      }
    } catch (e) {
      print('Error deleting profile image: $e');
    }
  }

  Future<void> loadProfilePicturePath(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? path = prefs.getString('profilePicturePath_$userId');
    if (path != null) {
      setState(() {
       // _profilePicturePath = 'https://leadproduct.000webhostapp.com/chessApi/$path';
        _profilePicturePath = 'https://schmidivan.com/Esakki/ChessGame/$path';
        userController.setProfilePicturePath(_profilePicturePath!);
      });
    }
  }

  Future getImageFromCamera(BuildContext context) async{
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _uploadImageAndUpdateProfile(context, currentUser.userId, File(pickedFile.path));
    } else {
      print('No image selected');
    }
  }

  Future getImageFromGallery(BuildContext context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _uploadImageAndUpdateProfile(context, currentUser.userId, File(pickedFile.path));
    } else {
      print('No image selected');
    }
  }
  Future<void> _uploadImageAndUpdateProfile( BuildContext context, String userId, File image,) async {
    setState(() {
      _isLoading = true;
    });

    try {

      Users currentUser = Get.find<CurrentUser>().users;
      var request = http.MultipartRequest(
        'POST',
       // Uri.parse('https://leadproduct.000webhostapp.com/chessApi/profile_image.php'),
          Uri.parse('https://schmidivan.com/Esakki/ChessGame/profile_image'),
      );
      request.fields['user_id'] =  currentUser.userId;
      request.fields['email'] = currentUser.email;
      String fileName = 'profile_image_$userId.jpg';

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          filename: fileName,
        ),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        // Get response body
        final responseBody = await response.stream.bytesToString();
        final imagePath = jsonDecode(responseBody)['imagePath'];
        // final String baseUrl = 'https://leadproduct.000webhostapp.com/chessApi/'; //
        const String baseUrl = 'https://schmidivan.com/Esakki/ChessGame/';
         final String imageUrl = baseUrl + imagePath; // Construct complete image URL  //
        setState(() {
          //_profilePicturePath = imagePath;
          _profilePicturePath = 'https://schmidivan.com/Esakki/ChessGame/$imagePath';
          userController.setProfilePicturePath(imageUrl);
        });
        // Save imagePath in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('profilePicturePath_$userId', imagePath);
        // Show success message or handle as needed
        print('Image uploaded successfully: $imagePath');
      } else {
        print('Failed to upload image');
      }
    } catch (e) {
      print('Error uploading image: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> saveImageLocally(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final imagePath = '$path/profile_image.png';
    final imageFile = File(imagePath);
    await imageFile.writeAsBytes(await image.readAsBytes());

    setState(() {
      _profilePicturePath = imagePath;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('localProfileImage', imagePath);
  }

  void updateProfileImageFromAsset(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final imageBytes = byteData.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final imagePath = '$path/selected_profile_image.png';
    final imageFile = File(imagePath);
    await imageFile.writeAsBytes(imageBytes);

    setState(() {
      _profilePicturePath = imagePath;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('localProfileImage', imagePath);
  }
  @override
  Widget build(BuildContext context,) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return _isLoading
        ? const Center(
        child: Indicator()
      //CircularProgressIndicator()
    )
        : ColorfulSafeArea(
      color: Colors.black,
      child: Scaffold(
        body:   SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
                  children: <Widget>[

                  ClipPath(
                    clipper: WaveClipper(),
                    child: Container(
                      height: screenHeight/4,
                      width: screenWidth/1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange, Colors.pink,Colors.red],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0),bottomRight: Radius.circular(20.0))
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                           GestureDetector(
                             onTap: () {
                               _showImageOptionsDialog(context);
                             },
                             child: _profilePicturePath != null
                                 ? CircleAvatar(
                                   radius: 50.0,
                                 //  backgroundImage: NetworkImage(_profilePicturePath!),
                                   backgroundImage: _profilePicturePath!.startsWith('http')
                                       ? NetworkImage(_profilePicturePath!)
                                       : FileImage(File(_profilePicturePath!)) as ImageProvider,
                                   onBackgroundImageError: (_, __) {
                                     setState(() {
                                       _profilePicturePath = null;
                                     });
                                  },
                                 )
                                 : const CircleAvatar(
                               radius: 50.0,
                               child: Icon(Icons.person),
                             ),

                           ),
                          // GestureDetector(
                          //   onTap: () {
                          //     _showImageOptionsDialog(context);
                          //   },
                          //   child:  _profilePicturePath != null
                          //   //userData.isNotEmpty
                          //       ? CircleAvatar(
                          //     radius: 50.0,
                          //     backgroundImage: NetworkImage(
                          //       'https://leadproduct.000webhostapp.com/chessApi/cheque/profile_image_${userData['user_id'] ?? ''}.jpg',
                          //     ),
                          //   )
                          //       : const CircleAvatar(
                          //        radius: 50.0,
                          //        child: Icon(Icons.person),
                          //   ),
                          // ),
                          const SizedBox(width: 50,),
                          Text(userData['name'] ?? '',style: TextStyle(color: Colors.white,fontSize: 20),)
                        ],
                      ),
                    ),
                  ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            updateProfileImageFromAsset('assets/lc-logo3.png');
                          },
                          child: Image(
                            image: AssetImage('assets/lc-logo3.png'),
                            height: 50,
                            width: 50,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            updateProfileImageFromAsset('assets/lc-logo3.png');
                          },
                          child: Image(
                            image: AssetImage('assets/lc-logo3.png'),
                            height: 50,
                            width: 50,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            updateProfileImageFromAsset('assets/lc-logo3.png');
                          },
                          child: Image(
                            image: AssetImage('assets/lc-logo3.png'),
                            height: 50,
                            width: 50,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            updateProfileImageFromAsset('assets/lc-logo3.png');
                          },
                          child: Image(
                            image: AssetImage('assets/lc-logo3.png'),
                            height: 50,
                            width: 50,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            updateProfileImageFromAsset('assets/lc-logo3.png');
                          },
                          child: Image(
                            image: AssetImage('assets/lc-logo3.png'),
                            height: 50,
                            width: 50,
                          ),
                        ),
                      ],
                    ),
                    MaterialButton(
                      child: Text('Button'),
                        onPressed: (){
                         // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NotificationPage()));
                        }
                    )
                ],
              ),
        ),
      ),
    );
  }

  void _showImageOptionsDialog(BuildContext context) {
    bool hasProfilePicture = _profilePicturePath != null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take camera Picture'),
                onTap: () {
                  Navigator.pop(context); // Close popup menu
                  getImageFromCamera(context); // Get image from camera
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context); // Close popup menu
                  getImageFromGallery(context); // Get image from gallery
                },
              ),
              if (hasProfilePicture)
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete Profile Picture'),
                  onTap: () {
                    Navigator.pop(context);
                    deleteProfileImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
  }


class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 20);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 20);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 40);
    var secondEndPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}