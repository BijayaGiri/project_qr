import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:try_qr/Text_to_QR.dart';
import 'package:string_validator/string_validator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:images_picker/images_picker.dart';
import 'package:scan/scan.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int count = 0;
  String qrcode = '';
  String? _scanBarcodeResult;

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      debugPrint(barcodeScanRes); //debugPrint() acts as same as the Print().
    } on PlatformException {
      barcodeScanRes = "Failed to get platfrom version";
    }
    if (!mounted)
      return; // mounted is a property that is used to check if a widget is still active before performing certain actions

    setState(() {
      _scanBarcodeResult = barcodeScanRes;
    });
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _scanBarcodeResult.toString()));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Copied to Clipboard"),
    ));
  }

  File? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xfffff1eb),
                Color(0xfface0f9),
              ]),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.07,
                ),
                Container(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(21),
                      child: Image(
                          width: MediaQuery.of(context).size.width * 0.95,
                          height: MediaQuery.of(context).size.height * 0.25,
                          fit: BoxFit.fill,
                          image: AssetImage("assets/images/QR_home.jpeg"))),
                ),
                SizedBox(
                  height: 50,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Text_To_QR();
                          }));
                        },
                        child: Text("Text To QR")),
                    SizedBox(width: 90),
                    ElevatedButton(
                        onPressed: scanBarcodeNormal,
                        child: Text("QR_Scanner")),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_scanBarcodeResult != null)
                      FittedBox(
                          child: Center(
                              child: Row(
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                _copyToClipboard();
                              },
                              child: Icon(
                                Icons.copy_all,
                                color: Colors.blue,
                              )),
                          Text("$_scanBarcodeResult"),
                        ],
                      ))),
                    SizedBox(
                      width: 10,
                    ),
                    if (isURL(_scanBarcodeResult.toString()) == true)
                      ElevatedButton(
                          onPressed: () async {
                            final Uri url = Uri.parse("$_scanBarcodeResult!");
                            if (!await launchUrl(url)) {
                              throw Exception("Could not launch");
                            }
                          },
                          child: Text("Search")),
                    ElevatedButton(

                        style:
                            ButtonStyle(elevation: MaterialStatePropertyAll(8)),
                        onPressed: () async {
                          count=count+1;
                          List<Media>? res = await ImagesPicker.pick();
                          if (res != null) {
                            String? str = await Scan.parse(res[0].path);
                            if (str != null) {
                              setState(() {
                                qrcode = str;
                              });
                            }
                          }
                        },
                        child: Text("From Gallery")),

                    if (qrcode != "")
                      FittedBox(
                        child: Center(
                          child: Row(
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    _copyToClipboard();
                                  },
                                  child: Icon(
                                    Icons.copy_all,
                                    color: Colors.blue,
                                  )),
                              Text("$qrcode")
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 10),
                    if (isURL(qrcode.toString()) == true)
                      ElevatedButton(
                          onPressed: () async {
                            final Uri url = Uri.parse("$qrcode");
                            if (!await launchUrl(url)) {
                              throw Exception("Could not launch");
                            }
                          },
                          child: Text("Search")),
                  ],
                )
              ],
            )));
  }
}
