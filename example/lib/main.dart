import 'package:flutter/material.dart';
import 'package:mlkit_scanner/mlkit_scanner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _barcode = 'Please, scan';
  var _zoomValues = [0.0, 0.33, 0.66];
  var _actialZoomIndex = 0;
  static const _delayOptions = {
    "0 milliseconds": 0,
    "100 milliseconds": 100,
    "500 milliseconds": 500,
    "2000 milliseconds": 2000,
  };
  BarcodeScannerController? _controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mlkit Scanner example app',
          ),
        ),
        body: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  child: BarcodeScanner(
                    cropOverlay:
                    const CropRect(scaleHeight: 0.7, scaleWidth: 0.7),
                    onScan: (code) {
                      setState(() {
                        _barcode = code['displayValue'];
                      });
                    },
                    onScannerInitialized: (controller) =>
                    _controller = controller,
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "Tap to focus on Center / LongTap to lock focus",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _barcode,
                style: TextStyle(fontSize: 18),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: SizedBox(
                    width: 88,
                    child: Text(
                      'Start scan',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onPressed: () => _controller?.startScan(100),
                ),
                const SizedBox(width: 8),
                TextButton(
                  child: SizedBox(
                    width: 88,
                    child: Text(
                      'Cancel scan',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onPressed: () => _controller?.cancelScan(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: SizedBox(
                    width: 88,
                    child: Text(
                      'Pause camera',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onPressed: () => _controller?.pauseCamera(),
                ),
                const SizedBox(width: 8),
                TextButton(
                  child: SizedBox(
                    width: 88,
                    child: Text(
                      'Resume camera',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onPressed: () => _controller?.resumeCamera(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: SizedBox(
                    width: 88,
                    child: Text(
                      'Toggle flash',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onPressed: () => _controller?.toggleFlash(),
                ),
                const SizedBox(width: 8),
                _buildDelayButton(),
              ],
            ),
            TextButton(
              child: SizedBox(
                width: 88,
                child: Text(
                  'Zoom',
                  textAlign: TextAlign.center,
                ),
              ),
              onPressed: () {
                _actialZoomIndex = _actialZoomIndex + 1 < _zoomValues.length
                    ? _actialZoomIndex + 1
                    : 0;
                _controller?.setZoom(_zoomValues[_actialZoomIndex]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDelayButton() {
    return TextButton(
      child: SizedBox(
        width: 88,
        child: PopupMenuButton<int>(
          onSelected: (delay) => _controller?.setDelay(delay),
          child: Text(
            'Set Delay',
            textAlign: TextAlign.center,
          ),
          itemBuilder: (context) {
            return _delayOptions.entries
                .map(
                  (entry) => PopupMenuItem(
                value: entry.value,
                child: Text(entry.key),
              ),
            )
                .toList();
          },
        ),
      ),
      onPressed: () {},
    );
  }
}
