//
//  VisionBarcodeScanner.swift
//  mlkit_scanner
//
//  Created by ООО "ДНС Технологии" on 05.03.2021.
//

import Foundation
import AVFoundation
import UIKit
import Vision

/// Barcode scanner recognizer, uses Apple Vision barcode detection.
///
/// Replaces MLKit on iOS: MLKit ships no arm64 simulator slice, so the plugin could not run on Apple Silicon simulators.
class VisionBarcodeScanner: NSObject, RecognitionHandler {
    private var delay: Int
    private var isDelayed = false
    private var cropRect: CropRect?
    private var isRecognitionInProgress = false

    var type: RecognitionType = RecognitionType.barcodeRecognition
    weak var delegate: RecognitionResultDelegate?

    /// Can the barcode be recognized.
    ///
    /// Used for optimization so as not to recognize the barcode on every frame.
    var canRecognize: Bool {
        !isDelayed && !isRecognitionInProgress
    }

    required init(delay: Int, cropRect: CropRect?) {
        self.delay = delay
        self.cropRect = cropRect
        super.init()
        startDelay()
    }

    /// Recognizes a barcode on frame [sampleBuffer].
    func processVideoOutput(sampleBuffer: CMSampleBuffer, scaleX: CGFloat, scaleY: CGFloat, orientation: AVCaptureVideoOrientation) {
        if (!canRecognize) {
            return
        }
        isRecognitionInProgress = true
        defer { isRecognitionInProgress = false }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let cimage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let cgImage = UIImage(ciImage: cimage, scaleX: scaleX, scaleY: scaleY, orientation: orientation, cropRect: cropRect)?.cgImage else {
            return
        }

        let request = VNDetectBarcodesRequest()
        request.symbologies = Array(VisionBarcodeScanner.formatCodes.keys)
        do {
            // The frame is already rotated by the capture connection, as it was for MLKit.
            try VNImageRequestHandler(cgImage: cgImage, orientation: .up).perform([request])
        } catch {
            DispatchQueue.main.async { [weak self] in self?.delegate?.onError(error: error) }
            return
        }
        guard let barcode = request.results?.first(where: { $0.payloadStringValue != nil }) else {
            return
        }
        let json = VisionBarcodeScanner.toJson(barcode)
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.onRecognition(result: json)
            self?.startDelay()
        }
    }

    func setDelay(delay: Int) {
        self.delay = delay
    }

    private func startDelay() {
        isDelayed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) { [weak self] in
            self?.isDelayed = false
        }
    }

    func updateCropRect(cropRect: CropRect) {
        self.cropRect = cropRect
    }

    /// Vision symbologies mapped to the MLKit format codes expected by the Dart side (`BarcodeFormatCode`).
    private static let formatCodes: [VNBarcodeSymbology: Int] = [
        .code128: 1,
        .code39: 2,
        .code39Checksum: 2,
        .code39FullASCII: 2,
        .code39FullASCIIChecksum: 2,
        .code93: 4,
        .code93i: 4,
        .codabar: 8,
        .dataMatrix: 16,
        .ean13: 32,
        .ean8: 64,
        .itf14: 128,
        .i2of5: 128,
        .i2of5Checksum: 128,
        .qr: 256,
        .upce: 1024,
        .pdf417: 2048,
        .aztec: 4096,
    ]

    /// Creates json for transmission over the platform channel, same keys as the former MLKit `Barcode.toJson()`.
    private static func toJson(_ barcode: VNBarcodeObservation) -> [String: Any?] {
        let value = barcode.payloadStringValue!
        let format = formatCodes[barcode.symbology] ?? 0
        return [
            "raw_value": value,
            "display_value": value,
            "format": format,
            "value_type": valueType(value: value, format: format),
        ]
    }

    /// Codes of `BarcodeValueTypeCode`: product (5) for EAN/UPC, url (8), otherwise text (7).
    // ponytail: Vision does not parse the payload like MLKit (wifi, contact, ...), add a parser if those types are needed.
    private static func valueType(value: String, format: Int) -> Int {
        if [32, 64, 1024].contains(format) {
            return 5
        }
        if let scheme = URL(string: value)?.scheme?.lowercased(), scheme == "http" || scheme == "https" {
            return 8
        }
        return 7
    }
}
