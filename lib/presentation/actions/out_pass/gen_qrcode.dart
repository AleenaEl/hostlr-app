import 'package:flutter/material.dart';
import 'package:hostlr_student/presentation/login_or_sign_up/login._page.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQrCode extends StatefulWidget {
  GenerateQrCode({Key? key}) : super(key: key);

  @override
  State<GenerateQrCode> createState() => _GenerateQrCodeState();
}

class _GenerateQrCodeState extends State<GenerateQrCode> {
  Map data = {};
  final TextEditingController _key = TextEditingController();
  final TextEditingController _value = TextEditingController();
  changeData(String key, String value) {
    setState(() {
      data.addAll({
        key: value,
      });
    });
  }

  removeData(String key) {
    setState(() {
      data.remove(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Current Data: $data'),
              QrImage(
                data: data.toString(),
                version: QrVersions.auto,
                size: 200.0,
              ),
              createFormBorderLessTextFeild(
                hintText: "Enter key",
                controller: _key,
              ),
              createFormBorderLessTextFeild(
                hintText: 'Enter value',
                controller: _value,
              ),
              MaterialButton(
                onPressed: () {
                  changeData(_key.text, _value.text);
                  _key.clear();
                  _value.clear();
                  setState(() {});
                },
                child: Text("Add Data"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
