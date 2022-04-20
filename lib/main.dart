import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'dialpad.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gọi điện đơn giản',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

@immutable
class DisplayContact {
  final String name;
  final String phoneNumber;

  const DisplayContact({this.name = '', this.phoneNumber = ''});
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  List<DisplayContact> contacts = [];

  void fetchContacts() async {
    if (await Permission.contacts.request().isGranted) {
      List<Contact> retContacts = await ContactsService.getContacts();
      List<DisplayContact> contacts = [];
      for (var r in retContacts) {
        r.phones?.forEach((p) {
          String name = r.displayName != null ? r.displayName! : "";
          String phoneNumber = p.value != null ? p.value! : "";
          contacts.add(DisplayContact(name: name, phoneNumber: phoneNumber));
        });
      }
      setState(() {
        this.contacts = contacts;
      });
    }
    debugPrint('Done: ${contacts.length}');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    fetchContacts();
  }

  callNumber(String phoneNumber) async {
    SystemSound.play(SystemSoundType.click);
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          bottomNavigationBar: menu(),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Scrollbar(
                child: ListView.builder(
                    padding: const EdgeInsets.only(top: 12),
                    itemCount: contacts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, top: 20, bottom: 20),
                        margin: const EdgeInsets.only(
                            bottom: 16, left: 16, right: 16),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Column(
                                children: [
                                  Text(contacts[index].name,
                                      style: const TextStyle(fontSize: 24)),
                                  Text(contacts[index].phoneNumber)
                                ],
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            ),
                            RawMaterialButton(
                              onPressed: () {
                                var phone = contacts[index]
                                    .phoneNumber
                                    .replaceAll(RegExp(r' '), '');
                                callNumber(phone);
                              },
                              elevation: 2.0,
                              fillColor: Colors.green,
                              child: const Icon(Icons.call,
                                  size: 32.0, color: Colors.white),
                              padding: const EdgeInsets.all(15.0),
                              shape: const CircleBorder(),
                            )
                          ],
                        ),
                      );
                    }),
              ),
              const DialPad()
            ],
          ),
        ),
      ),
    );
  }

  Widget menu() {
    return Container(
      color: const Color(0xFF3F5AA6),
      child: const TabBar(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.all(5.0),
        indicatorColor: Colors.blue,
        labelStyle: TextStyle(fontSize: 16),
        tabs: [
          Tab(
            text: "Danh bạ",
            icon: Icon(Icons.contact_phone),
          ),
          Tab(
            text: "Gọi điện",
            icon: Icon(Icons.call),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint("app in resumed");
        break;
      case AppLifecycleState.inactive:
        debugPrint("app in inactive");
        break;
      case AppLifecycleState.paused:
        debugPrint("app in paused");
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        break;
      case AppLifecycleState.detached:
        debugPrint("app in detached");
        break;
    }
  }
}
