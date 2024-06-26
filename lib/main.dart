//import 'dart:ffi';

//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hanhai/chater/room_page.dart';
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'webs/web_body.dart';
import 'screens/welcome_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/message_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'subscribe/survey.dart';
import 'books/books_updated.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Adding this to the styles.xml helped me
  //<item name="android:windowLayoutInDisplayCutoutMode">shortEdges</item>
  final client = Client(
    "Matrix Hanhai Chat",
    databaseBuilder: (p0) async {
      final dir = await getApplicationSupportDirectory();
      final db = HiveCollectionsDatabase('matrix_example_chat', dir.path);
      await db.open();
      return db;
    },
  );
  await client.init();

  runApp(MyApp(client: client));
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

class MyApp extends StatelessWidget {
  final Client client;
  const MyApp({super.key, required this.client});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '瀚海',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/chat': (context) => ChatScreen(
              client: client,
            ),
        '/message': (context) => MessageScreen(
              client: client,
            ),
        '/profile': (context) => ProfileScreen(
              client: client,
            ),
        '/login': (context) => LoginScreen(
              client: client,
            ),
        '/register': (context) => RegisterScreen(client: client,),
        // '/loading': (context) => LoadingScreen(
        //       client: client,
        //     ),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) => Provider<Client>(
        create: (context) => client,
        child: child,
      ),
      home: MyHomePage(
        title: '瀚海',
        client: client,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.client});
  final Client client;
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class AppOptions extends _MyHomePageState {
  static BuildContext? theContext;
  static String url = "url";
  static bool canPopValue = false;
  static bool webHomeLoading = true;
  static int times = 0;
  static Client? client;
  Dio dio = Dio();
  void changeCanPopState(bool isTrue) {
    if (isTrue) {
      canPopValue = true;
    } else {
      canPopValue = false;
    }
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final lastPopTime = DateTime.now();
  int currentIndex = 0;
  BookShelves bookShelves = const BookShelves();
  WebHomeWidget webHomeWidget = const WebHomeWidget();
  late RoomInterface roomInterface;
  SurveyWidgets surveySelect = const SurveyWidgets();
  late ProfileScreen profileScreen;
  @override
  void initState() {
    super.initState();
    // 在 initState 中初始化 roomInterface，以确保可以访问 widget.client
    roomInterface = RoomInterface(client: widget.client);
    profileScreen = ProfileScreen(client: widget.client);
  }

  @override
  Widget build(BuildContext context) {
    AppOptions.theContext = context;
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "主页"),
          NavigationDestination(icon: Icon(Icons.shopping_bag), label: "订阅"),
          NavigationDestination(icon: Icon(Icons.book), label: "书库"),
        ],
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      body: <Widget>[webHomeWidget, surveySelect, bookShelves][currentIndex],
    );
  }
}
