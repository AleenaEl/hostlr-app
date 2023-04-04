import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hostlr_student/main.dart';
import 'package:hostlr_student/model/user/user_model.dart';
import 'package:hostlr_student/presentation/actions/fees/bill_payment.dart';
import 'package:hostlr_student/presentation/actions/out_pass/create_outpass.dart';
import 'package:hostlr_student/presentation/actions/out_pass/gen_qrcode.dart';
import 'package:hostlr_student/presentation/actions/out_pass/out_pass.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/retry.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _cuurentPage = 0;
  final PageController _controller = PageController();

  final storage = const FlutterSecureStorage();
  HostlrUser? user;
  List<dynamic> alerts = [];
  @override
  void initState() {
    _getAlerts();
    super.initState();
  }

  Future<HostlrUser?> _getUserData() async {
    try {
      final String? token = await storage.read(key: 'token');
      final String? uid = await storage.read(key: 'uid');
      var url =
          Uri.parse('https://hostlr-server.herokuapp.com/users/data/$uid');
      log(token.toString());
      log(uid.toString());
      var response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      log('Response status: ${response.statusCode} ${jsonDecode(response.body.toString())}');
      if (response.statusCode == 200) {
        return HostlrUser.fromJson(jsonDecode(response.body)["userdata"]);
      } else {
        log("Somthing went wrong");
        return null;
      }
    } catch (e) {
      log("Error occured in login -->" + e.toString());
      return null;
    }
  }

  Future<void> _getAlerts() async {
    try {
      final String? token = await storage.read(key: 'token');
      var url = Uri.parse('https://hostlr-server.herokuapp.com/alerts');
      var response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      log('Response status: ${response.statusCode} ${jsonDecode(response.body.toString())}');
      if (response.statusCode == 200) {
        setState(() {
          alerts = jsonDecode(response.body.toString())["Alerts"];
        });
      } else {
        log("Somthing went wrong");
      }
    } catch (e) {
      log("Error occured in login -->" + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HostlrUser?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          return Scaffold(
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 90, 68, 188),
                    ),
                    child: Center(
                        child: Text(
                      '.hostlr',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 34,
                        fontWeight: FontWeight.w400,
                      ),
                    )),
                  ),
                  ListTile(
                    leading: Icon(Icons.info),
                    title: const Text('About Developers'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: Text(
                "hostlr.",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 90, 68, 188),
                      backgroundImage: snapshot.data != null
                          ? NetworkImage(snapshot.data!.imageUrl)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            body: PageView(
              onPageChanged: (e) {
                setState(() {
                  _cuurentPage = e;
                });
              },
              controller: _controller,
              children: [
                PageOne(
                  alerts: alerts,
                ),
                PageTwo(),
                PageThree(
                  user: snapshot.data,
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _cuurentPage,
              onTap: (e) {
                setState(() {
                  _cuurentPage = e;
                });
                _controller.jumpToPage(e);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_activity),
                  label: 'Actions',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        });
  }
}

class PageOne extends StatefulWidget {
  final List<dynamic> alerts;
  const PageOne({Key? key, required this.alerts}) : super(key: key);

  @override
  State<PageOne> createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> {
  final storage = const FlutterSecureStorage();
  List<dynamic> quickActions = [];
  @override
  void initState() {
    super.initState();
    getQuickActions();
  }

  void getQuickActions() async {
    try {
      log("Quick Actions");
      final String? token = await storage.read(key: 'token');
      // final String? uid = await storage.read(key: 'uid');
      var url =
          Uri.parse('https://hostlr-server.herokuapp.com/app/get-actions');
      var response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      log('Response status: ${response.statusCode} ${jsonDecode(response.body.toString())}');
      if (response.statusCode == 200) {
        setState(() {
          quickActions = jsonDecode(response.body)["actions"];
        });
        return;
      } else {
        log("Somthing went wrong");
        return;
      }
    } catch (e) {
      log("Error the $e");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search hostlr.",
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              "Quick Acess",
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(
            height: 110,
            child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateOutPass(),
                          ));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: const Color.fromARGB(255, 90, 68, 188)
                            .withOpacity(0.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.card_giftcard,
                            color: Colors.white,
                            size: 30,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Gate Pass",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.all(5),
                      height: 100,
                      width: 100,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BillPayment(),
                          ));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: const Color.fromARGB(255, 90, 68, 188)
                            .withOpacity(0.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.payment,
                            color: Colors.white,
                            size: 30,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Bill Payment",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.all(5),
                      height: 100,
                      width: 100,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: const Color.fromARGB(255, 90, 68, 188)
                            .withOpacity(0.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.list,
                            color: Colors.white,
                            size: 30,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Attendance",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.all(5),
                      height: 100,
                      width: 100,
                    ),
                  )
                ]),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              "Alerts",
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(
            height: 360,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {},
                child: Container(
                  margin: EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 8,
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color:
                        const Color.fromARGB(255, 90, 68, 188).withOpacity(0.1),
                  ),
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.withOpacity(0.3),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(widget.alerts[index]["icon"]),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.alerts[index]["title"],
                                style: GoogleFonts.poppins(
                                  color: Colors.black.withOpacity(1),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Container(
                                width: 300,
                                child: Text(
                                  widget.alerts[index]["subtitle"],
                                  style: GoogleFonts.poppins(
                                    color: Colors.black.withOpacity(0.6),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              itemCount: widget.alerts.length,
            ),
          )
        ],
      ),
    );
  }
}

class PageTwo extends StatefulWidget {
  const PageTwo({
    Key? key,
  }) : super(key: key);

  @override
  State<PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              "Actions",
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxHeight: 620),
            child: GridView(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateOutPass(),
                        ));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color.fromARGB(255, 90, 68, 188)
                          .withOpacity(0.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.card_giftcard,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Gate Pass",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.all(5),
                    height: 100,
                    width: 100,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BillPayment(),
                        ));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color.fromARGB(255, 90, 68, 188)
                          .withOpacity(0.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Bill Payment",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.all(5),
                    height: 100,
                    width: 100,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color.fromARGB(255, 90, 68, 188)
                          .withOpacity(0.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.list,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Attendance",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.all(5),
                    height: 100,
                    width: 100,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class PageThree extends StatefulWidget {
  final HostlrUser? user;
  const PageThree({Key? key, this.user}) : super(key: key);

  @override
  State<PageThree> createState() => _PageThreeState();
}

class _PageThreeState extends State<PageThree> {
  final storage = const FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return const Center(
        child: Text("Loading"),
      );
    }
    final user = widget.user!;
    return SingleChildScrollView(
      child: Container(
        color: Colors.black.withAlpha(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 15,
            ),
            Center(
              child: CircleAvatar(
                radius: 80,
                backgroundColor: const Color.fromARGB(190, 90, 68, 188),
                backgroundImage: NetworkImage(user.imageUrl.toString()),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            detailsBox(
              heading: "Basic Details",
              onTap: () {},
              children: [
                detailsRow(
                    key: "Name",
                    value: user.firstName + " " + user.lastName,
                    padding: 8),
                detailsRow(key: "Email", value: user.email, padding: 8),
                detailsRow(
                    key: "Phone Number", value: user.phoneNumber, padding: 8),
              ],
            ),
            detailsBox(
              heading: "Academic Details",
              onTap: () {},
              children: [
                detailsRow(
                  key: "College",
                  value: user.collageCode,
                  padding: 8,
                ),
                detailsRow(
                  key: "Year of Joining",
                  value: user.yearOfAdmission,
                  padding: 8,
                ),
                detailsRow(
                  key: "Branch",
                  value: user.branchCode,
                  padding: 8,
                ),
                detailsRow(
                  key: "Roll No.",
                  value: user.rollNo,
                  padding: 8,
                ),
              ],
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                child: MaterialButton(
                  focusElevation: 0,
                  elevation: 0,
                  hoverElevation: 0,
                  highlightElevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: const Color.fromARGB(190, 90, 68, 188),
                  minWidth: double.infinity,
                  onPressed: () async {
                    await storage.deleteAll();
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SplashScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Logout",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget detailsRow({
  required String key,
  required String value,
  double padding = 5,
}) {
  return Container(
    padding: EdgeInsets.all(padding),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          key,
          style: GoogleFonts.poppins(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget detailsBox({
  required String heading,
  required Function onTap,
  required List<Widget> children,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(
      vertical: 10,
      horizontal: 15,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(13),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          offset: const Offset(0, 2),
          blurRadius: 12,
          spreadRadius: 5,
          color: Colors.black.withAlpha(20),
        )
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Column(
        children: [
          ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    heading,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Material(
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.edit,
                        color: Color.fromARGB(200, 90, 68, 188),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ],
          ...children
        ],
      ),
    ),
  );
}
