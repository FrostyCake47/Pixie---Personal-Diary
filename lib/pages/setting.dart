import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:fluttertoast/fluttertoast.dart';


class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  late List<SettingTile> settingTileList;


  @override
  void initState() {
    super.initState();
    settingTileList = [
    SettingTile(title: "Login/Register", icon: Icons.perm_identity_rounded, desc: "Login to your account", iconColor: Colors.blue[700], ontap: goToLogin,),
    SettingTile(title: "Change password", icon: Icons.password, desc: "Reset your current password", iconColor: Colors.grey[600], ontap: changePass,),
    SettingTile(title: "Export/Import", icon: Icons.cloud, desc: "Backup your save files or retrieve them", iconColor: Colors.blueAccent[300], ontap: goToBackup),
    SettingTile(title: "Logout", icon: Icons.logout_outlined, desc: "Logout from the current account", iconColor: Colors.grey[600], ontap: logout),
    SettingTile(title: "About me", icon: Icons.favorite, desc: "Mwaaa my first app", iconColor: Colors.redAccent[400], ontap: doNothing,),
    ];
  }

  void goToLogin(){
    Navigator.pushNamed(context, "/auth");
  }

  void doNothing(){}
  
  void changePass(){
    var passlocker = Hive.box<String>('passlock');
    passlocker.clear();
    Fluttertoast.showToast(
      msg: "Password has been reset. Restart app to set new password",
      toastLength: Toast.LENGTH_LONG
      );
    
  }

  void logout() async {
    print("logout function");
    if(FirebaseAuth.instance.currentUser != null){
      
      showDialog(context: context, builder: (context){
        return const Center(
            child: SpinKitCircle(
              color: Colors.redAccent,
              size: 50.0,
            ),
          );
      });
      
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Logged out");
    }
    else {
      print("user already logged out");
      Fluttertoast.showToast(msg: "User already logged out");
    }
  }

  void goToBackup(){
    FirebaseAuth.instance.currentUser == null ? 
    Fluttertoast.showToast(msg: 'Login in to continue') : 
    Navigator.pushNamed(context, '/backup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),),
      ),
      body: ListView.builder(itemCount: settingTileList.length ,itemBuilder: (context, index){
        return settingTileList[index];
      }),
    );
  }
}


class SettingTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String desc;
  final Color? iconColor;
  final void Function()? ontap;

  const SettingTile({super.key, required this.title, required this.icon, required this.desc, required this.iconColor, required this.ontap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(20)),
        tileColor: Colors.grey[900],
        leading: Icon(icon, color: iconColor,),
        title: Text(title),
        subtitle: Text(desc, style: TextStyle(color: Colors.grey[400])),
      
        textColor: Colors.white,
        iconColor: Colors.white,

        onTap: ontap,
      ),
    );
  }
}