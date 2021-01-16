//
//  CodeReader.swift
//  Runner
//
//  Created by Fabrício Silva Carvalhal on 02/12/20.
//

import AVFoundation
import UIKit

protocol CodeReader {
    func startReading(completion: @escaping (String) -> Void)
    func stopReading()
    var videoPreview: CALayer {get}
    var authorization: AVAuthorizationStatus { get }
    var hasCameraAvailable: Bool { get }
}

class AVCodeReader: NSObject {
    
    private(set) var videoPreview = CALayer()
    
    private var captureSession: AVCaptureSession?
    private var didRead: ((String) -> Void)?

    private let barCodeTypes = [AVMetadataObject.ObjectType.upce,
                                AVMetadataObject.ObjectType.code39,
                                AVMetadataObject.ObjectType.code39Mod43,
                                AVMetadataObject.ObjectType.code93,
                                AVMetadataObject.ObjectType.code128,
                                AVMetadataObject.ObjectType.ean8,
                                AVMetadataObject.ObjectType.ean13,
                                AVMetadataObject.ObjectType.aztec,
                                AVMetadataObject.ObjectType.pdf417,
                                AVMetadataObject.ObjectType.itf14,
                                AVMetadataObject.ObjectType.dataMatrix,
                                AVMetadataObject.ObjectType.interleaved2of5]
    
    override init() {
        super.init()
        
        guard let videoDevice = AVCaptureDevice.default(for: .video),
            let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
                return
        }
        captureSession = AVCaptureSession()
        
        captureSession?.addInput(deviceInput)
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = barCodeTypes
        
        let captureVideoPreview = AVCaptureVideoPreviewLayer(session: captureSession!)
        captureVideoPreview.videoGravity = .resizeAspectFill
        self.videoPreview = captureVideoPreview
    }
    
    func handleCapturedOutput(metadataObjects: [AVMetadataObject]) {
        if metadataObjects.count == 0 {
            return
        }
        
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            return
        }
        
        if barCodeTypes.contains(metadataObject.type) {
            if let metaDataString = metadataObject.stringValue {
                didRead?(metaDataString)
            }
        }
    }
    
}

extension AVCodeReader: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        handleCapturedOutput(metadataObjects: metadataObjects)
    }

}

extension AVCodeReader: CodeReader {
    var hasCameraAvailable: Bool {
        (AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) != nil) ||
        (AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil)
    }
    

    var authorization: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    func startReading(completion: @escaping (String) -> Void) {
        DispatchQueue.global().async { [weak self] in
            self?.didRead = completion
            self?.captureSession?.startRunning()
        }
    }
    func stopReading() {
        captureSession?.stopRunning()
    }
    
}
