// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:learning_input_image/learning_input_image.dart';
// import 'package:learning_text_recognition/learning_text_recognition.dart';
// import 'package:provider/provider.dart';
// import 'package:text_recognition/ocr_detection.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.lightBlue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//         primaryTextTheme: TextTheme(
//           headline6: TextStyle(color: Colors.white),
//         ),
//       ),
//       home: ChangeNotifierProvider(
//         create: (_) => TextRecognitionState(),
//         child: TextRecognitionPage(),
//       ),
//       // home: OCRPage(),
//     );
//   }
// }

// class TextRecognitionPage extends StatefulWidget {
//   @override
//   _TextRecognitionPageState createState() => _TextRecognitionPageState();
// }

// class _TextRecognitionPageState extends State<TextRecognitionPage> {
//   TextRecognition? _textRecognition = TextRecognition();
  

//   /* TextRecognition? _textRecognition = TextRecognition(
//     options: TextRecognitionOptions.Japanese
//   ); */

//   @override
//   void dispose() {
//     _textRecognition?.dispose();
//     super.dispose();
//   }

//   Future<void> _startRecognition(InputImage image) async {
//     TextRecognitionState state = Provider.of(context, listen: false);

//     if (state.isNotProcessing) {
//       state.startProcessing();
//       state.image = image;
//       state.data = await _textRecognition?.process(image);
//       state.stopProcessing();
//       state.text.replaceAll(RegExp('[^A-Za-z0-9]'), '') == "B236086" ? Get.offAll(OCRPage()): null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return InputCameraView(
//       mode: InputCameraMode.gallery,
//       resolutionPreset: ResolutionPreset.high,
//       title: 'Text Recognition',
//       onImage: _startRecognition,
//       overlay: Consumer<TextRecognitionState>(
//         builder: (_, state, __) {
//           if (state.isNotEmpty) {
//             return Center(
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.8),
//                   borderRadius: BorderRadius.all(Radius.circular(4.0)),
//                 ),
//                 child: Text(
//                   state.text,
//                   style: TextStyle(
//                     color: Colors.deepOrange,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             );
//           }

         
//          return Container();
//         },
//       ),
//     );
//   }
// }

// class TextRecognitionState extends ChangeNotifier {
//   InputImage? _image;
//   RecognizedText? _data;
//   bool _isProcessing = false;
//   late List plates = [];
//   InputImage? get image => _image;
//   RecognizedText? get data => _data;
//   String get text => _data!.text;
//   bool get isNotProcessing => !_isProcessing;
//   bool get isNotEmpty => _data != null && text.isNotEmpty;

//   void startProcessing() {
//     _isProcessing = true;
//     notifyListeners();
//   }

//   void stopProcessing() {
//     _isProcessing = false;
//     notifyListeners();
//   }

//   set image(InputImage? image) {
//     _image = image;
//     notifyListeners();
//   }

//   set data(RecognizedText? data) {
//     _data = data;
//     String temp = _data!.text.replaceAll(RegExp('[^A-Za-z0-9]'), '');
//     print(temp);
//     plates.add(_data!.text.split("\n"));
//     print(plates);
//     notifyListeners();
//     // if(temp == "B236086")
//     //   Get.offAll(OCRPage());
//   }


// }


import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
// image_picker: ^0.7.2
import 'package:image_picker/image_picker.dart';
// camera: ^0.8.1
import 'package:camera/camera.dart';
import 'package:camera_process/camera_process.dart';
import 'package:text_recognition/ocr_detection.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMART GAS'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ListTile(
                    tileColor: Theme.of(context).primaryColor,
                    title: const Text(
                      'ALPR',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                     Get.to(()=>TextDetectorView());
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TextDetectorView extends StatefulWidget {
  @override
  _TextDetectorViewState createState() => _TextDetectorViewState();
}

class _TextDetectorViewState extends State<TextDetectorView> {
  TextDetector textDetector = CameraProcess.vision.textDetector();
  bool isBusy = false;
  CustomPaint? customPaint;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  late String userId;
  late String userName;
  @override
  void dispose() async {
    super.dispose();
    await textDetector.close();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'ALPR SCANNER',
      customPaint: customPaint,
      onImage: (inputImage) {
        processImage(inputImage);
      },
    );
  }

  Future<void> getUser(String pn) async {
  final getId = await FirebaseFirestore.instance.collection('users').get().then((value) => {
    
    value.docs.forEach((element) async {
      final result = await FirebaseFirestore.instance.collection('users').doc(element.id).collection("cars").where("licensePlate",isEqualTo: pn).get();
      if(result.docs.isNotEmpty ){
        userId = element.id;
  }
    })
  });
  // final result = await FirebaseFirestore.instance.collection('users').doc("Ucjv3WnURpWHlTaCoRZBynfYCvM2").collection("cars").where("licensePlate",isEqualTo: pn).get();
  
}
Future<void> getUserName(String id) async {
  
    final fullName = await FirebaseFirestore.instance.collection('users').where("id",isEqualTo: id).get();
   userName = fullName.docs.first.data()['name'];
    
  }

  Future<void> processImage(InputImage inputImage) async {
     if (isBusy) return;
    isBusy = true;
    //final recognisedText = await textDetector.processImage(inputImage);
    final recognisedText = await textDetector.processImage(inputImage);
    print(recognisedText.text);
    print('Found ${recognisedText.blocks.length} textBlocks');
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = TextDetectorPainter(
          recognisedText,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      customPaint = CustomPaint(painter: painter);
    } else {
      customPaint = null;
    }
    isBusy = false;
    
    if(recognisedText.text.isNotEmpty){
      Future.delayed(Duration(seconds: 3), () async{
      getUser(recognisedText.text);
      await getUserName(userId);
      if(userId.isNotEmpty){
        
         Get.off(()=>OCRPage(userID: userId,userName: userName));
         //Get.snackbar("Mingles SIKO BIKO", userId);
         //Get.delete();
      }
      
           
      });
      
    }
    if (mounted) {
      setState(() {});
    }
  }
}




enum ScreenMode { liveFeed}

class CameraView extends StatefulWidget {
  CameraView(
      {Key? key,
      required this.title,
      required this.customPaint,
      required this.onImage,
      this.initialDirection = CameraLensDirection.back})
      : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  ScreenMode _mode = ScreenMode.liveFeed;
  CameraController? _controller;
  File? _image;
  ImagePicker? _imagePicker = ImagePicker();
  int _cameraIndex = 0;

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();
    for (var i = 0; i < cameras.length; i++) {
      if (cameras[i].lensDirection == widget.initialDirection) {
        _cameraIndex = i;
      }
    }
    _startLiveFeed();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _liveFeedBody(),
      floatingActionButton: _floatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget? _floatingActionButton() {
    if (cameras.length == 1) return null;
    return Container(
        height: 70.0,
        width: 70.0,
        child: FloatingActionButton(
          child: Icon(
            Platform.isIOS
                ? Icons.flip_camera_ios_outlined
                : Icons.flip_camera_android_outlined,
            size: 40,
          ),
          onPressed: _switchLiveCamera,
        ));
  }


  Widget _liveFeedBody() {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CameraPreview(_controller!),
          if (widget.customPaint != null) widget.customPaint!,
        ],
      ),
    );
  }

 

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _switchLiveCamera() async {
    if (_cameraIndex == 0)
      _cameraIndex = 1;
    else
      _cameraIndex = 0;
    await _stopLiveFeed();
    await _startLiveFeed();
  }


  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex];
    final imageRotation =
        InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw) ??
            InputImageFormat.NV21;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    widget.onImage(inputImage);
  }
}

// -------------------------------------------------------------

class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(
      this.recognisedText, this.absoluteImageSize, this.rotation);

  final RecognisedText recognisedText;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.lightGreenAccent;

    final Paint background = Paint()..color = Color(0x99000000);

    for (final textBlock in recognisedText.blocks) {
      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
            textAlign: TextAlign.left,
            fontSize: 16,
            textDirection: TextDirection.ltr),
      );
      builder.pushStyle(
          ui.TextStyle(color: Colors.lightGreenAccent, background: background));
      builder.addText('${textBlock.text}');
      builder.pop();

      final left =
          translateX(textBlock.rect.left, rotation, size, absoluteImageSize);
      final top =
          translateY(textBlock.rect.top, rotation, size, absoluteImageSize);
      final right =
          translateX(textBlock.rect.right, rotation, size, absoluteImageSize);
      final bottom =
          translateY(textBlock.rect.bottom, rotation, size, absoluteImageSize);

      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paint,
      );

      canvas.drawParagraph(
        builder.build()
          ..layout(ParagraphConstraints(
            width: right - left,
          )),
        Offset(left, top),
      );
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return oldDelegate.recognisedText != recognisedText;
  }
}


double translateX(
    double x, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.Rotation_90deg:
      return x *
          size.width /
          (Platform.isIOS ? absoluteImageSize.width : absoluteImageSize.height);
    case InputImageRotation.Rotation_270deg:
      return size.width -
          x *
              size.width /
              (Platform.isIOS
                  ? absoluteImageSize.width
                  : absoluteImageSize.height);
    default:
      return x * size.width / absoluteImageSize.width;
  }
}

double translateY(
    double y, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.Rotation_90deg:
    case InputImageRotation.Rotation_270deg:
      return y *
          size.height /
          (Platform.isIOS ? absoluteImageSize.height : absoluteImageSize.width);
    default:
      return y * size.height / absoluteImageSize.height;
  }
}