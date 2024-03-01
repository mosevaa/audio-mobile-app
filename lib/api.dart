import 'dart:io';

import 'package:http/http.dart' as http;

class MyAPI {
  MyAPI();

  Future<void> sendFile(File file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http'),
    );

    final len = file.lengthSync();

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        file.readAsBytesSync(),
        filename: 'file.mp3',
      ),
    );

    request.fields.addAll(
      {
        'identity': '',
        'token': ''
      }
    );

    final res = await request.send();
    final respStr = await res.stream.bytesToString();
    print(res);
  }
}