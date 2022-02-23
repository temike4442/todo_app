import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lock_screen/flutter_lock_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}

class SplashScreen extends StatelessWidget {

  Future<bool> check_prefs() async {
    final prefs = await SharedPreferences.getInstance();
    final int? counter = prefs.getInt('counter');
    if (counter != null) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: check_prefs(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData)
            return snapshot.data == true ? PassCodeScreen() :
            MainScreen();
          else
            return CircularProgressIndicator();
        });
  }
}

class MainScreen extends StatefulWidget {
  _MainScreenState createState() => new _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  Future<void> set_prefs(String _key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, 10);
  }

  Future<void> delete_prefs(String _key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:
      ListView(
      children: [
      ExpansionTile(
      title: Text('Задачи'),
      children: [
        ListView.builder(
          shrinkWrap: true,
          itemCount: 4,
          itemBuilder: (context, index) =>
              ListTile(title: Text("4"),),
        )
      ],
    ),
    ],
    )
    );
  }
}


class PassCodeScreen extends StatefulWidget {
  PassCodeScreen({Key? key}) : super(key: key);

  @override
  _PassCodeScreenState createState() => new _PassCodeScreenState();
}

class _PassCodeScreenState extends State<PassCodeScreen> {
  @override
  Widget build(BuildContext context) {
    bool isFingerprint = false;

    Future<Null> biometrics() async {
      final LocalAuthentication auth = new LocalAuthentication();
      bool authenticated = false;

      try {
        authenticated = await auth.authenticate(
            localizedReason: 'Авторизация отпечатками',
            useErrorDialogs: true,
            stickyAuth: false);
      } on PlatformException catch (e) {
        print(e);
      }
      if (!mounted) return;
      if (authenticated) {
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(builder: (BuildContext context) {
              return MainScreen();
            }));
      }
    }

    var myPass = [1, 2, 3, 4];
    return LockScreen(
        title: "Код блокировки",
        passLength: 4,
        bgImage: "assets/images/bg.jpg",
        fingerPrintImage: Image.asset(
          "assets/images/finger.png",
          height: 60,
          width: 60,
        ),
        showFingerPass: true,
        fingerFunction: biometrics,
        fingerVerify: isFingerprint,
        borderColor: Colors.white,
        showWrongPassDialog: true,
        wrongPassContent: "Неверный код блокировки",
        wrongPassTitle: "Уупс!",
        wrongPassCancelButtonText: "Отмена",
        passCodeVerify: (passcode) async {
          for (int i = 0; i < myPass.length; i++) {
            if (passcode[i] != myPass[i]) {
              return false;
            }
          }
          return true;
        },
        onSuccess: () {
          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (BuildContext context) {
                return MainScreen();
              }));
        });
  }
}