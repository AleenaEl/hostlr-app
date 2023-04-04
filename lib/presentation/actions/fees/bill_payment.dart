import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BillPayment extends StatefulWidget {
  BillPayment({Key? key}) : super(key: key);

  @override
  State<BillPayment> createState() => _BillPaymentState();
}

class _BillPaymentState extends State<BillPayment> {
  List<dynamic> payments = [
    {
      "id": "RERD682929",
      "title": "Fee for April 2022",
      "amount": "4899.0",
      'paid': true,
    },
    {
      "id": "RERD66929",
      "title": "Fee for June 2022",
      "amount": "4700.0",
      'paid': true,
    },
    {
      "id": "RERD677929",
      "title": "Fee for July 2022",
      "amount": "4899.0",
      'paid': false,
    },
  ].reversed.toList();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment History"),
        elevation: 0,
        toolbarHeight: 90,
        backgroundColor: Color.fromARGB(255, 90, 68, 188).withOpacity(0.8),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: payments.length,
                itemBuilder: ((context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(-1, -1),
                                color: Colors.black.withAlpha(10),
                                blurRadius: 12,
                                spreadRadius: 8,
                              )
                            ],
                            color: !payments[index]["paid"]
                                ? Colors.white
                                : Colors.purple.withOpacity(0.1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "#" + payments[index]["id"],
                                        style: GoogleFonts.poppins(
                                          color: Colors.black.withOpacity(0.3),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        payments[index]["title"],
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "₹" + payments[index]["amount"],
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(),
                                ),
                                if (!payments[index]["paid"])
                                  MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18)),
                                    onPressed: () {},
                                    color: Color.fromARGB(255, 90, 68, 188),
                                    child: Text(
                                      "Pay Now",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                if (payments[index]["paid"])
                                  MaterialButton(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18)),
                                    onPressed: () {},
                                    color: Color.fromARGB(255, 90, 68, 188)
                                        .withOpacity(0.2),
                                    child: Text(
                                      "Paid",
                                      style: GoogleFonts.poppins(
                                        color: Color.fromARGB(255, 90, 68, 188),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                SizedBox(
                                  width: 10,
                                )
                              ],
                            ),
                          ),
                        ),
                        if (!payments[index]["paid"])
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              height: 20,
                              width: 70,
                              child: Center(
                                  child: Text(
                                "Not Paid",
                                style: TextStyle(color: Colors.white),
                              )),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: Colors.red,
                              ),
                            ),
                          )
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
