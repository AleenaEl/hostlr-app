import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hostlr_student/main.dart';
import 'package:hostlr_student/model/user/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isExpanded = false;
  final PageController _controller = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: !isExpanded,
        extendBodyBehindAppBar: true,
        appBar: isExpanded
            ? AppBar(
                title: Text("Registeration"),
                elevation: 0,
                toolbarHeight: 90,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  onPressed: () {
                    _controller.previousPage(
                      duration: Duration(milliseconds: 10),
                      curve: Curves.ease,
                    );
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
              )
            : null,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    "https://firebasestorage.googleapis.com/v0/b/doozy-e2caa.appspot.com/o/dark-blue-"
                    "technology-background-free-vector.jpg?alt=media&token=bb368978-f726-4801-8a08-f92b54257377",
                  ),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 90, 68, 188).withOpacity(0.7),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 160,
                  ),
                  Text(
                    "hostlr.",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ],
              ),
            ),
            Theme(
              data: ThemeData(
                colorScheme: ColorScheme.fromSwatch().copyWith(
                  primary: Color.fromARGB(255, 90, 68, 188),
                  secondary: Color.fromARGB(255, 90, 68, 188).withOpacity(0.6),
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: isExpanded ? 710 : 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    color: Colors.white,
                  ),
                  child: PageView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _controller,
                    onPageChanged: (e) {
                      isExpanded = !(e == 0);
                      setState(() {});
                      log(e.toString());
                    },
                    children: [
                      OldUserTab(pageController: _controller),
                      RegisterUserTab(
                        pageController: _controller,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

class OldUserTab extends StatefulWidget {
  final PageController pageController;
  const OldUserTab({Key? key, required this.pageController}) : super(key: key);

  @override
  State<OldUserTab> createState() => _OldUserTabState();
}

class _OldUserTabState extends State<OldUserTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final storage = FlutterSecureStorage();
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  Future<void> _loginWithEmailAndPassword() async {
    try {
      setState(() {
        isLoading = true;
      });
      if (_formKey.currentState!.validate()) {
        var url = Uri.parse('https://hostlr-server.herokuapp.com/users/login');
        var response = await http.post(url,
            body: jsonEncode({
              'email': _emailController.text,
              'password': _passwordController.text,
            }),
            headers: {
              "Content-Type": "application/json",
            });
        log('Response status: ${response.statusCode} ${jsonDecode(response.body)}');
        if (response.statusCode == 200) {
          await storage.write(
            key: 'token',
            value: jsonDecode(response.body)['token'],
          );
          await storage.write(
              key: 'uid', value: jsonDecode(response.body)["user"]['id']);
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SplashScreen(),
            ),
          );
        } else {
          log("Wrong email or password.");
          showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text("Invalid Credentials"),
              content: Text(
                "The credentials you provided seems invalid.Please try again.",
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        }
      } else {
        log("Enter valid credentials.");
        showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text("Invalid Credentials"),
            content: Text(
              "The credentials you provided seems invalid.Please try again.",
            ),
            actions: [
              CupertinoDialogAction(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("Something went wrong"),
          content: Text(
            "An un-expected error occured : (${e.toString()})",
          ),
          actions: [
            CupertinoDialogAction(
              child: Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
      log("Error occured in login -->" + e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back",
                          style: GoogleFonts.poppins(
                            color: Color.fromARGB(255, 90, 68, 188)
                                .withOpacity(0.8),
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          "Please enter your credentials.",
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  createFormBorderLessTextFeild(
                      hintText: "Email",
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid email';
                        } else {
                          bool emailValid = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value.toString());
                          if (emailValid) {
                            return null;
                          } else {
                            return "Invalid Email";
                          }
                        }
                      }),
                  SizedBox(
                    height: 20,
                  ),
                  createFormBorderLessTextFeild(
                    controller: _passwordController,
                    hintText: 'Password',
                    obsecure: true,
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  MaterialButton(
                    minWidth: 300,
                    height: 40,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    color: Color.fromARGB(255, 90, 68, 188),
                    onPressed: () async {
                      await _loginWithEmailAndPassword();
                    },
                    child: Text(
                      "Login",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  TextButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19)),
                      ),
                    ),
                    onPressed: () {
                      widget.pageController.nextPage(
                          duration: Duration(milliseconds: 100),
                          curve: Curves.easeIn);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: RichText(
                        text: TextSpan(
                          text: "Do you have an account? ",
                          style: GoogleFonts.poppins(
                            color: Colors.grey.withOpacity(1),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          children: const <TextSpan>[
                            TextSpan(
                                text: 'Register Here.',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Signing in...'),
                    SizedBox(height: 10),
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      color: Colors.purple.withOpacity(0.05),
                      elevation: 0,
                      onPressed: () {
                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: Text("Cancel"),
                    )
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}

class RegisterUserTab extends StatefulWidget {
  final PageController pageController;
  const RegisterUserTab({Key? key, required this.pageController})
      : super(key: key);

  @override
  State<RegisterUserTab> createState() => _RegisterUserTabState();
}

class _RegisterUserTabState extends State<RegisterUserTab> {
  bool expandedPage = false;
  String password = "";
  String? imageUrl;
  final storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _collageController = TextEditingController();
  final TextEditingController _hostelController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _classRollNumberController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _yearOfJoinigController = TextEditingController();

  bool isSubmitting = false;
  bool isUploadingImage = false;

  Future<String?> uploadImageAndGetUrl() async {
    setState(() {
      isUploadingImage = true;
    });
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxHeight: 400,
        maxWidth: 400,
      );
      if (image != null) {
        File file = File(image.path);
        final ref = FirebaseStorage.instance
            .ref('/profile_images/${DateTime.now().millisecondsSinceEpoch}');
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': file.path},
        );
        final url =
            await ref.putFile(File(file.path), metadata).then((p0) async {
          return (await p0.ref.getDownloadURL());
        });
        return url;
      }
      return null;
    } catch (e) {
      log(e.toString());
      showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("Registration Failed"),
          content: Text(
            "An error occured while uploading your data. Please try again.",
          ),
          actions: [
            CupertinoDialogAction(
              child: Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
      return null;
    } finally {
      setState(() {
        isUploadingImage = false;
      });
    }
  }

  Future<HostlrUser?> _createUser() async {
    setState(() {
      isSubmitting = true;
    });
    try {
      //log all text fields
      log(_firstName.text);
      log(_lastName.text);
      log(_emailController.text);
      log(_collageController.text);
      log(_hostelController.text);
      log(_branchController.text);
      log(_classRollNumberController.text);
      log(_passwordController.text);
      log(_confirmPasswordController.text);
      log(_phoneNumberController.text);
      log(_yearOfJoinigController.text);

      //create user
      final user = HostlrUser(
        firstName: _firstName.text,
        lastName: _lastName.text,
        userName: _emailController.text,
        email: _emailController.text,
        collageCode: _collageController.text,
        stayId: _hostelController.text,
        branchCode: _branchController.text,
        rollNo: _classRollNumberController.text,
        phoneNumber: _phoneNumberController.text,
        yearOfAdmission: _yearOfJoinigController.text,
      );
      //log user
      log(user.toJson().toString());
      var url = Uri.parse('https://hostlr-server.herokuapp.com/users/create');
      var response = await http.post(url,
          body: jsonEncode({
            ...user.toJson(),
            ...{
              'password': _passwordController.text,
              'imageUrl': imageUrl,
            }
          }),
          headers: {
            "Content-Type": "application/json",
          });
      log('Response status: ${response.statusCode} ${jsonDecode(response.body)["user"]}');
      if (response.statusCode == 200) {
        await storage.write(
          key: 'token',
          value: jsonDecode(response.body)['token'],
        );
        await storage.write(
            key: 'uid', value: jsonDecode(response.body)["user"]['id']);
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SplashScreen(),
          ),
        );
      }
      return HostlrUser.fromJson(jsonDecode(response.body)["user"]);
    } catch (e) {
      log("Uploading image error -> " + e.toString());
      return null;
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  String value = 'option';
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: LayoutBuilder(builder: (context, constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Aloo there.",
                          style: GoogleFonts.poppins(
                            color: Color.fromARGB(255, 90, 68, 188)
                                .withOpacity(0.8),
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          "Please fill in your details.",
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (constraints.maxHeight > 500)
                  SizedBox(
                    height: 500,
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: ((overscroll) {
                        overscroll.disallowIndicator();
                        return true;
                      }),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 40,
                                ),
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 70,
                                      child: isUploadingImage
                                          ? CircularProgressIndicator()
                                          : (imageUrl == null
                                              ? Icon(
                                                  Icons.person,
                                                  color: Color.fromARGB(
                                                      255, 90, 68, 188),
                                                  size: 50,
                                                )
                                              : null),
                                      backgroundColor: Colors.grey.shade100,
                                      backgroundImage: imageUrl == null
                                          ? null
                                          : NetworkImage(imageUrl.toString()),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: Material(
                                          color:
                                              Color.fromARGB(255, 90, 68, 188),
                                          child: IconButton(
                                            color: Colors.white,
                                            icon: Icon(Icons.edit),
                                            onPressed: () async {
                                              await uploadImageAndGetUrl()
                                                  .then((value) {
                                                log(value.toString());
                                                setState(() {
                                                  imageUrl = value;
                                                });
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                createFormBorderLessTextFeild(
                                  controller: _firstName,
                                  hintText: 'First Name',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'This feild cannot be empty';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                createFormBorderLessTextFeild(
                                  controller: _lastName,
                                  hintText: 'Last Name',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'This feild cannot be empty';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                createFormBorderLessTextFeild(
                                  controller: _emailController,
                                  hintText: 'Email',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a valid email';
                                    } else {
                                      bool emailValid = RegExp(
                                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(value.toString());
                                      if (emailValid) {
                                        return null;
                                      } else {
                                        return "Invalid Email";
                                      }
                                    }
                                  },
                                ),
                                CustomDropDownButton(
                                  hintText: "Year of admission",
                                  controller: _yearOfJoinigController,
                                  options: List.generate(
                                          (DateTime.now().year % 100) + 3,
                                          (e) => (e + 2000))
                                      .where((element) =>
                                          element >
                                          (2000 +
                                              ((DateTime.now().year % 100) -
                                                  6)))
                                      .map((e) => e.toString())
                                      .toList(),
                                ),
                                CustomDropDownButton(
                                  hintText: "Select Institute",
                                  controller: _collageController,
                                  options: const [
                                    "MBI",
                                  ],
                                ),
                                CustomDropDownButton(
                                  hintText: "Select branch",
                                  controller: _branchController,
                                  options: const [
                                    "CSE",
                                    "ECE",
                                    "EEE",
                                    "CIVIL",
                                    "MECH",
                                    "IT",
                                    "OTHER",
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                createFormBorderLessTextFeild(
                                  controller: _classRollNumberController,
                                  hintText: 'Roll No.',
                                  validator: (e) {
                                    if (int.tryParse(e.toString()) == null) {
                                      return "Inavalid value.";
                                    } else {
                                      if (int.tryParse(e.toString())! > 80) {
                                        return "Enter a valid value";
                                      } else {
                                        return null;
                                      }
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                createFormBorderLessTextFeild(
                                  controller: _phoneNumberController,
                                  hintText: "Phone No.",
                                  validator: (value) {
                                    if (value.toString().length != 10) {
                                      return 'Mobile Number must be of 10 digit';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                CustomDropDownButton(
                                  hintText: "Staying at",
                                  controller: _hostelController,
                                  options: const [
                                    "MBITS Men's Hostel (MH)",
                                    "MBITS Ladies's Hostel (LH)",
                                    'Other',
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                createFormBorderLessTextFeild(
                                    controller: _passwordController,
                                    hintText: "Password",
                                    obsecure: true,
                                    onChange: (e) {
                                      setState(() {
                                        password = e;
                                      });
                                      log(password);
                                    },
                                    validator: (e) {
                                      if (e == null || e.isEmpty) {
                                        return "This feild cannot be empty";
                                      }
                                      if (e.toString().length < 8) {
                                        return "Password length must be greater than 8";
                                      } else {
                                        return null;
                                      }
                                    }),
                                SizedBox(
                                  height: 20,
                                ),
                                createFormBorderLessTextFeild(
                                    controller: _confirmPasswordController,
                                    hintText: "Confirm Password",
                                    obsecure: true,
                                    onChange: (e) {
                                      log(password);
                                    },
                                    validator: (password) {
                                      if (password == null ||
                                          password.isEmpty) {
                                        return "This feild cannot be empty";
                                      }

                                      if (password != this.password) {
                                        return "Password does not match";
                                      } else {
                                        return null;
                                      }
                                    }),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).viewInsets.bottom,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Column(
                  children: [
                    SizedBox(
                      height: 20,
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
                            const SnackBar(content: Text('Processing Data')),
                          );
                          final hostler = await _createUser();
                          if (hostler != null) {}
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
                    SizedBox(
                      height: 8,
                    ),
                    TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19)),
                        ),
                      ),
                      onPressed: () {
                        widget.pageController.previousPage(
                          duration: Duration(milliseconds: 10),
                          curve: Curves.ease,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: RichText(
                          text: TextSpan(
                            text: "Have an account? ",
                            style: GoogleFonts.poppins(
                              color: Colors.grey.withOpacity(1),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            children: const <TextSpan>[
                              TextSpan(
                                  text: 'Login',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
        if (isSubmitting)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Registration in progress."),
                  SizedBox(height: 20),
                  MaterialButton(
                    color: Colors.purple.withOpacity(0.05),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    onPressed: () {
                      setState(() {
                        isSubmitting = false;
                      });
                    },
                    child: Text("Cancel"),
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }
}

TextFormField createFormBorderLessTextFeild({
  TextEditingController? controller,
  String? hintText,
  bool? obsecure,
  String? Function(String?)? validator,
  void Function(String)? onChange,
  void Function()? onTap,
  bool? readOnly,
}) {
  return TextFormField(
    onTap: onTap,
    controller: controller,
    onChanged: onChange,
    readOnly: readOnly ?? false,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: validator,
    style: GoogleFonts.poppins(
      color: Colors.black,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    obscureText: obsecure ?? false,
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        color: Colors.grey,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

// class FormBorderLessTextFeild extends StatelessWidget {
//   final TextEditingController? controller;
//   final String? hintText;
//   final bool? obsecure;
//   const FormBorderLessTextFeild({
//     Key? key,
//     required this.controller,
//     required this.hintText,
//     this.obsecure = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         children: [
//           SizedBox(
//             height: 20,
//           ),
//         ],
//       ),
//     );
//   }
// }

class CustomDropDownButton extends StatefulWidget {
  final String? hintText;
  final List<String> options;
  final TextEditingController controller;
  const CustomDropDownButton({
    Key? key,
    this.hintText = 'Select a value',
    required this.controller,
    required this.options,
  }) : super(key: key);

  @override
  State<CustomDropDownButton> createState() => _CustomDropDownButtonState();
}

class _CustomDropDownButtonState extends State<CustomDropDownButton> {
  String dropdownValue = '';
  @override
  void initState() {
    // TODO: implement initState
    dropdownValue = widget.options.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        TextFormField(
          readOnly: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please choose a value.';
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          controller: widget.controller,
          decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              suffixIcon: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Color.fromARGB(255, 90, 68, 188),
                ),
                child: DropdownButton<String>(
                  icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                  elevation: 0,
                  style: const TextStyle(color: Colors.white),
                  underline: Container(
                    height: 0,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                      widget.controller.text = newValue;
                    });
                  },
                  items: widget.options
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )),
        ),
      ],
    );
  }
}
