import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:get/get.dart';

import 'package:getx_music/screen/main_tab/main_tab_screen.dart';
import 'package:getx_music/screen/mini_player/mini_player_controller.dart';
import 'package:getx_music/src/API/spotify_api.dart';
import 'package:hive/hive.dart';
import "package:hive_flutter/hive_flutter.dart";
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig

  await FlutterConfig.loadEnvVariables();
  await Hive.initFlutter();
  await Hive.openBox(HiveConst.setting);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          title: 'Flutter Demo',
          theme: initialTheme(context: context),
          getPages: [
            GetPage(
              name: MainTabScreen.routeName,
              page: () => MainTabScreen(),
            ),
          ],
          initialRoute: MainTabScreen.routeName,
          initialBinding: InitialBinding(),
        );
      },
    );
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SpotifyService());
    Get.put(MiniPlayerController());
  }
}

ThemeData initialTheme({required BuildContext context}) {
  return ThemeData(
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
    ),
    dividerColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.white),
    scaffoldBackgroundColor: Colors.black,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
    ),
    textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
  );
}

class HiveConst {
  static final setting = "settings";
  static final String predicts = "predicts";
}
