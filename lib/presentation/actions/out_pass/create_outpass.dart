import 'dart:convert';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hostlr_student/presentation/login_or_sign_up/login._page.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CreateOutPass extends StatefulWidget {
  CreateOutPass({Key? key}) : super(key: key);

  @override
  State<CreateOutPass> createState() => _CreateOutPassState();
}

class _CreateOutPassState extends State<CreateOutPass> {
  FlutterSecureStorage storage = FlutterSecureStorage();
  List<dynamic> outPass = [];
  createOutPass() {
    showDialog(
        context: context,
        builder: (context) => OutPassForm(
              onDone: getOutPass,
            ),
        barrierDismissible: false,
        barrierColor: Colors.white38);
  }

  getOutPass() async {
    final uid = await storage.read(key: 'uid');
    final token = await storage.read(key: 'token');
    log(token.toString());
    var url = Uri.parse('https://hostlr-server.herokuapp.com/outpass/$uid');
    var response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        outPass = jsonDecode(response.body.toString())["pass_list"];
        outPass.sort(((a, b) => a["issued_time"].compareTo(b["issued_time"])));
        outPass = outPass.reversed.toList();
      });
    }
  }

  @override
  void initState() {
    getOutPass();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createOutPass();
        },
        child: Icon(
          Icons.card_giftcard,
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
          "Gate Pass",
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
                child: IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                getOutPass();
              },
            )),
          ),
        ],
      ),
      body: PageView(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: outPass.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: outPass[index]["verify_id"] == null
                        ? Color.fromARGB(234, 90, 68, 188)
                        : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: 3,
                        offset: Offset(1, -1),
                        color: Colors.black.withAlpha(10),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              outPass[index]["type"] == 1
                                  ? Text(
                                      "Homegoing Pass",
                                      style: GoogleFonts.poppins(
                                        color: outPass[index]["verify_id"] ==
                                                null
                                            ? Colors.white
                                            : Color.fromARGB(255, 90, 68, 188)
                                                .withOpacity(0.8),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  : Text(
                                      "Outgoing Pass",
                                      style: GoogleFonts.poppins(
                                        color: outPass[index]["verify_id"] ==
                                                null
                                            ? Colors.white
                                            : Color.fromARGB(255, 90, 68, 188)
                                                .withOpacity(0.8),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Reason: ${outPass[index]["reason"]}",
                                style: GoogleFonts.poppins(
                                  color: outPass[index]["verify_id"] == null
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                "Issue Time: ${DateTime.fromMillisecondsSinceEpoch(outPass[index]["issued_time"])}",
                                style: GoogleFonts.poppins(
                                  color: outPass[index]["verify_id"] == null
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                "Validity Till: ${DateTime.fromMillisecondsSinceEpoch(outPass[index]["expiry_time"])}",
                                style: GoogleFonts.poppins(
                                  color: outPass[index]["verify_id"] == null
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                "Verified At Gate: ${outPass[index]["verify_id"] == null ? "Not Verified" : "Verified"}",
                                style: GoogleFonts.poppins(
                                  color: outPass[index]["verify_id"] == null
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              barrierColor: Colors.white,
                              context: context,
                              builder: (context) => AlertDialog(
                                content: Container(
                                  height: 250,
                                  width: 250,
                                  child: Center(
                                    child: QrImage(
                                      foregroundColor: Colors.black,
                                      data: outPass[index]["_id"],
                                      version: QrVersions.auto,
                                      size: 250.0,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: QrImage(
                            foregroundColor: outPass[index]["verify_id"] != null
                                ? Colors.black
                                : Colors.white,
                            data: outPass[index]["_id"],
                            version: QrVersions.auto,
                            size: 150.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class OutPassForm extends StatefulWidget {
  final onDone;
  OutPassForm({Key? key, required this.onDone}) : super(key: key);

  @override
  State<OutPassForm> createState() => _OutPassFormState();
}

class _OutPassFormState extends State<OutPassForm> {
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  TextEditingController _controllerTypeOfPass = TextEditingController();
  TextEditingController _expiryTimeController = TextEditingController();
  TextEditingController _emergencyContactController = TextEditingController();
  int? expiryTime;
  bool isLoading = false;
  TextEditingController _reason = TextEditingController();
  @override
  void initState() {
    _controllerTypeOfPass.addListener(() {
      _expiryTimeController.clear();
      expiryTime = null;
      setState(() {});
    });
    super.initState();
  }

  Future<bool> createPass() async {
    try {
      setState(() {
        isLoading = true;
      });
      final uid = await storage.read(key: 'uid');
      final token = await storage.read(key: 'token');
      log(token.toString());
      var url = Uri.parse('https://hostlr-server.herokuapp.com/outpass/create');
      var response = await http.post(
        url,
        body: jsonEncode(
          {
            'student_id': uid,
            'reason': _reason.text,
            'emergencyContact': _emergencyContactController.text,
            'issued_time': DateTime.now().millisecondsSinceEpoch,
            'expiry_time': expiryTime,
            'exit_time': DateTime.now()
                .add(Duration(minutes: 10))
                .millisecondsSinceEpoch,
            'type': _controllerTypeOfPass.text == 'Outgoing' ? 0 : 1,
          },
        ),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json",
        },
      );

      log('Response status: ${response.statusCode} ${jsonDecode(response.body)}');
      Navigator.pop(context);
      widget.onDone();
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Form(
              key: _formKey,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(1, 1),
                      blurRadius: 18,
                      spreadRadius: 0,
                      color: Colors.black.withAlpha(20),
                    )
                  ],
                ),
                height: 550,
                width: 350,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Create Outpass",
                          style: GoogleFonts.poppins(
                            color: Color.fromARGB(255, 90, 68, 188)
                                .withOpacity(0.8),
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          "Please fill in the details.",
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        CustomDropDownButton(
                          hintText: "Type of pass",
                          controller: _controllerTypeOfPass,
                          options: const [
                            "Outgoing",
                            'Homegoing',
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        createFormBorderLessTextFeild(
                            hintText: 'Place and Reason',
                            controller: _reason,
                            validator: (e) {
                              if (e.toString().length < 3) {
                                return 'Enter a valid reason';
                              }
                              return null;
                            }),
                        SizedBox(
                          height: 10,
                        ),
                        createFormBorderLessTextFeild(
                          controller: _expiryTimeController,
                          onChange: (e) {
                            log(e);
                          },
                          hintText: 'Return Time',
                          readOnly: true,
                          onTap: () async {
                            if (_controllerTypeOfPass.text == 'Homegoing') {
                              final dateTime = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  Duration(
                                    days: (365 * 4),
                                  ),
                                ),
                              );
                              if (dateTime != null) {
                                expiryTime = dateTime.millisecondsSinceEpoch;
                                _expiryTimeController.text =
                                    '${dateTime.day}-${dateTime.month}-${dateTime.year}';
                              }
                              return;
                            }
                            final dateTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (dateTime != null) {
                              final expiryDate = DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                                dateTime.hour,
                                dateTime.minute,
                              );
                              expiryTime = expiryDate.millisecondsSinceEpoch;
                              _expiryTimeController.text =
                                  'Today at ${dateTime.hour}:${dateTime.minute}';
                            }
                          },
                          validator: (e) {
                            if (e.toString().length < 3) {
                              return 'Select valid Date Or Time';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        createFormBorderLessTextFeild(
                          hintText: 'Emergency Contact Info (Optional)',
                          controller: _emergencyContactController,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        MaterialButton(
                          minWidth: 300,
                          height: 40,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          color: Color.fromARGB(255, 90, 68, 188),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Processing Data')),
                              );
                              await createPass();
                            }
                          },
                          child: Text(
                            "Continue",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          height:
                              MediaQuery.of(context).viewInsets.bottom / 1.5,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (isLoading)
              Container(
                height: 550,
                width: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white70,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitCircle(
                        itemBuilder: ((context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: index % 2 == 0
                                  ? Color.fromARGB(255, 90, 68, 188)
                                  : Color.fromARGB(100, 90, 68, 188),
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                      Text(
                        'Please wait',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            Positioned(
              top: -8,
              right: -8,
              child: GestureDetector(
                onTap: () {
                  if (!isLoading) Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 90, 68, 188),
                    shape: BoxShape.circle,
                  ),
                  height: 30,
                  width: 30,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
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
