import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
class Text_To_QR extends StatefulWidget {
  const Text_To_QR({super.key});

  @override
  State<Text_To_QR> createState() => _Text_To_QRState();
}

class _Text_To_QRState extends State<Text_To_QR> {
  GlobalKey globalKey = new GlobalKey();
  GlobalKey _qrkey = GlobalKey();
  dynamic externalDir = '/storage/emulated/0/DCIM/'
      'Qr_code';
  bool dirExists = false;
  String qrData = "";
  Future<void> _captureAndSavePng() async {
    try {
      if (globalKey.currentContext == null) {
        print("Error:_qrkey.currentContext is null");
        return;
      }
      final boundary = globalKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        print("Error:RenderRepaintBoundary not found");
        return;
      }
      var image = await boundary.toImage(pixelRatio: 3.0);
      //Drawing White Background because Qr Code is Black
      final whitePaint = Paint()..color = Colors.white;
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));
      canvas.drawRect(
          Rect.fromLTRB(image.width.toDouble() * 0.2, 0,
              image.width.toDouble() * 0.8, image.height.toDouble()),
          whitePaint);
      canvas.drawImage(image, Offset.zero, Paint());
      final picture = recorder.endRecording();
      final img = await picture.toImage(image.width, image.height);
      ByteData? byteData = await img.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      //Check for duplicate file name to avoid Override
      String fileName = 'qr_code';
      int i = 1;
      while (await File('$externalDir/$fileName.png').exists()) {
        fileName = 'qr_code_$i';
        i++;
      }

      // Check if Directory Path exists or not
      dirExists = await File(externalDir).exists();
      //if not then create the path
      if (!dirExists) {
        await Directory(externalDir).create(recursive: true);
        dirExists = true;
      }

      final file = await File('$externalDir/$fileName.png').create();
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;
      const snackBar = SnackBar(content: Text('QR code saved to gallery'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      if (!mounted) return;
      print('Error:$e');
      const snackBar = SnackBar(content: Text('Something went wrong!!!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xfffff1eb),
            Color(0xfface0f9),
          ]),
        ),
        child: Column(children: [
          SizedBox(
            height: 150,
          ),
          RepaintBoundary(
            key: globalKey,
            child: Container(
              child: Center(
                  child: qrData.isEmpty
                      ? Text(
                          "Enter the Data to Generate QR",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                            color: Colors.blueGrey,
                          ),
                        )
                      : QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 200,
                        )),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.8,
            child: TextField(
              textAlign: TextAlign.start,
              decoration: InputDecoration(
               contentPadding: EdgeInsets.all(0.0),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(21),
                ),
                hintText: "Enter the data",
                prefixIcon: Icon(Icons.qr_code_2_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  qrData = value;
                });
              },
            ),
          ),
          RepaintBoundary(
              key: _qrkey,
              child: ElevatedButton(
                  onPressed: _captureAndSavePng, child: Text("Export")))
        ]),
      ),
    );
  }
}
