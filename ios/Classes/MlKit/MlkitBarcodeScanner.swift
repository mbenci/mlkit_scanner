//
//  MlkitBarcodeScanner.swift
//  mlkit_scanner
//
//  Created by ООО "ДНС Технологии" on 05.03.2021.
//

import Foundation
import AVFoundation
import MLKitBarcodeScanning
import MLKitVision

/// Barcode scanner recognizer, uses MLkit Barcode Scanning API
class MlkitBarcodeScanner: NSObject, RecognitionHandler {
    private let scanner: BarcodeScanner
    private var delay: Int
    private var isDelayed = false
    private var cropRect: CropRect?
    
    var type: RecognitionType = RecognitionType.barcodeRecognition
    weak var delegate: RecognitionResultDelegate?
    
    required init(delay: Int, cropRect: CropRect?) {
        scanner = BarcodeScanner.barcodeScanner()
        self.delay = delay
        self.cropRect = cropRect
        super.init()
        startDelay()
    }
    
    func proccessVideoOutput(sampleBuffer: CMSampleBuffer, scaleX: CGFloat, scaleY: CGFloat, orientation: AVCaptureVideoOrientation) {
        if isDelayed {
            return
        }
        startDelay()
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let cimage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let image = UIImage(ciImage: cimage, scaleX: scaleX, scaleY: scaleY, orientation: orientation, cropRect: cropRect) else {
            return
        }
        let visionImage = VisionImage(image: image)
        scanner.process(visionImage) { [weak self] features, error in
            if let error = error {
                self?.delegate?.onError(error: error)
                return
            }
            guard let features = features, !features.isEmpty else {
                return
            }
            guard let rawValue = features.first?.rawValue else { return }
            guard let displayValue = features.first?.displayValue else { return }
            guard let format = features.first?.format.rawValue else { return }
            guard let valueType = features.first?.valueType.rawValue else { return }

            /* print("externalInternalShared: \(features.first?.rawValue) : \(features.first?.displayValue)") */

            var barcode:[String:String] = ["rawValue":String(rawValue), "displayValue":String(displayValue), "format":String(format), "valueType":String(valueType) ]

            self?.delegate?.onRecognition(result: barcode)
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
}
