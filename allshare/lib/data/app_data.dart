import 'package:flutter/foundation.dart';
import '../model/profileData.dart';

class AppData extends ChangeNotifier {
  ProfileData? localUserInfo;
  ProfileData? remoteUserInfo;
  //AppData Controllers

  setUserInfo(ProfileData x, ProfileData y) {
    localUserInfo = x;
    remoteUserInfo = y;
    notifyListeners();
  }
}
