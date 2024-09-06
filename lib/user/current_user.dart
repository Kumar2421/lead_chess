


import 'package:chess_game/user/user_preference.dart';
import 'package:chess_game/user/users.dart';
import 'package:get/get.dart';


class CurrentUser extends GetxController
{
  final Rx<Users> _currentUser = Users(
    mobile: 'mobile', name: 'name', email: 'email',
    //password: 'password',
    sessionToken: 'session_token', userId: 'user_id', imagePath: 'image_path',
    flag: 'country_flag',
    //betting_amount: 'betting_amount',
  ).obs;
  Users get users => _currentUser.value;
  getUserInfo() async
  {
    Users? getUserInfoFromLocalStorage = await RememberUserPrefs.readUserInfo();
    _currentUser.value = getUserInfoFromLocalStorage?? Users(
      mobile: 'mobile', name: 'name', email: 'email',
      //password: 'password',
      sessionToken: 'session_token', userId: 'user_id', imagePath: 'image_path',
      flag: 'country_flag',
      //betting_amount: 'betting_amount',
    );
  }
  String getCurrentUserId() {
    return _currentUser.value.userId; // Accessing userid property
  }
  String getCurrentUserImagePath() {
    return _currentUser.value.imagePath; // Accessing userid property
  }
}

class UserController extends GetxController {
  var profilePicturePath = ''.obs;

  void setProfilePicturePath(String path) {
    profilePicturePath.value = path;
  }
  void deleteProfilePicturePath() {
    profilePicturePath.value = '';
  }
}