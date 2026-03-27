import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class SAFPlugin {
  static const platform = const MethodChannel('com.perol.dev/saf');

  static Future<String?> createFile(String name, String type) async {
    final result = await platform.invokeMethod("createFile", {
      'name': name,
      'mimeType': type,
    });
    if (result != null) {
      return result;
    }
    return null;
  }

  static Future<void> writeUri(String uri, Uint8List data) async {
    return platform.invokeMethod("writeUri", {'uri': uri, 'data': data});
  }

  static Future<String?> exportFile(
    String name,
    Uint8List data, {
    String mimeType = 'application/octet-stream',
  }) async {
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      final extension = _extensionFromFileName(name);
      final location = await getSaveLocation(
        suggestedName: name,
        acceptedTypeGroups: [
          XTypeGroup(
            label: extension ?? mimeType,
            extensions: extension == null ? null : [extension],
          ),
        ],
      );
      if (location == null) return null;
      final file = File(location.path);
      await file.writeAsBytes(data);
      return file.path;
    }

    final uri = await createFile(name, mimeType);
    if (uri == null) return null;
    await writeUri(uri, data);
    return uri;
  }

  static Future<Uint8List?> pickFile() async {
    if (Platform.isIOS) {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles();
        if (result != null) {
          return File(result.files.single.path!).readAsBytes();
        }
      } catch (e) {}
      return null;
    }

    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      try {
        final file = await openFile(
          acceptedTypeGroups: [
            XTypeGroup(label: 'json', extensions: ['json']),
          ],
        );

        if (file != null) {
          return await file.readAsBytes();
        }
      } catch (e) {
        print(e);
      }
      return null;
    }

    try {
      return await platform.invokeMethod<Uint8List>("openFile", {
        'type': "application/json",
      });
    } catch (e) {
      print(e);
      return null;
    }
  }

  static String? _extensionFromFileName(String name) {
    final index = name.lastIndexOf('.');
    if (index == -1 || index == name.length - 1) {
      return null;
    }
    return name.substring(index + 1).toLowerCase();
  }
}
