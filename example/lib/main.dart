import 'dart:async';
import 'dart:io';
import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _imagePath;
  List<File> images = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> getImageFromCamera() async {
    bool isCameraGranted = await Permission.camera.request().isGranted;
    if (!isCameraGranted) {
      isCameraGranted =
          await Permission.camera.request() == PermissionStatus.granted;
    }

    if (!isCameraGranted) {
      // Have not permission to camera
      return;
    }

    // Generate filepath for saving
    String imagePath = join((await getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

    bool success = false;

    try {
      //Make sure to await the call to detectEdge.
      success = await EdgeDetection.detectEdge(
        imagePath,
        canUseGallery: true,
        androidScanTitle: 'Scanning', // use custom localizations for android
        androidCropTitle: 'Crop',
        androidCropBlackWhiteTitle: 'Black White',
        androidCropReset: 'Reset',
      );
      print("success: $success");
    } catch (e) {
      print(e);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      if (success) {
        // _imagePath = imagePath;
        images.add(File(imagePath));
      }
    });
  }

  Future<void> getImageFromGallery() async {
    // Generate filepath for saving
    String imagePath = join((await getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

    bool success = false;
    try {
      //Make sure to await the call to detectEdgeFromGallery.
      success = await EdgeDetection.detectEdgeFromGallery(
        imagePath,
        androidCropTitle: 'Crop', // use custom localizations for android
        androidCropBlackWhiteTitle: 'Black White',
        androidCropReset: 'Reset',
      );
      print("success: $success");
    } catch (e) {
      print(e);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      if (success) {
        images.add(File(imagePath));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton(
                onPressed: getImageFromCamera,
                child: Text('Scan'),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: getImageFromGallery,
                child: Text('Upload'),
              ),
            ),
            SizedBox(height: 20),
            Text('Cropped image path:'),
            Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
              child: Text(
                _imagePath.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
            Visibility(
              visible: images.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ImageReorderScreen(imageFiles: images),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageReorderScreen extends StatefulWidget {
  final List<File> imageFiles;

  const ImageReorderScreen({Key? key, required this.imageFiles})
      : super(key: key);
  @override
  _ImageReorderScreenState createState() => _ImageReorderScreenState();
}

class _ImageReorderScreenState extends State<ImageReorderScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: ReorderableListView(
          onReorder: _onReorder,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.all(6),
          children: List.generate(
              widget.imageFiles.length,
              (index) => Row(
                    key: Key(widget.imageFiles[index].path),
                    children: [
                      SizedBox(width: 8,),
                      Image.file(
                        widget.imageFiles[index],
                        key: Key(widget.imageFiles[index]
                            .path), // Unique key for each list item
                        width: 200,
                        height: 200,
                      ),
                    ],
                  ))),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final image = widget.imageFiles.removeAt(oldIndex);
      widget.imageFiles.insert(newIndex, image);
      print(widget.imageFiles);
    });
  }
}
