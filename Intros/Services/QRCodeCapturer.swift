import Foundation
import AVFoundation

import RxSwift
import CleanroomLogger

class QRCodeCapturer: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    let captureSession = AVCaptureSession()
    
    private let metadataSubject: PublishSubject<AVMetadataMachineReadableCodeObject> = PublishSubject()
    private let queue: dispatch_queue_t
    
    private var isSetup = false
    
    var qrCode: Observable<AVMetadataMachineReadableCodeObject> {
        return metadataSubject
    }
    
    init(queue: dispatch_queue_t) {
        self.queue = queue
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        guard let metadataObjects = metadataObjects else {
            return
        }
        
        for metadataObject in metadataObjects {
            guard let metadataObject = metadataObject as? AVMetadataMachineReadableCodeObject else {
                continue
            }
            
            if metadataObject.type == AVMetadataObjectTypeQRCode {
                Log.debug?.message("Captured QR code: \(metadataObject)")
                metadataSubject.onNext(metadataObject)
            }
        }
    }
    
    func startCapture() throws {
        if !isSetup {
            let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: queue)
            
            isSetup = true
        }
        
        captureSession.startRunning()
    }
    
    func stopCapture() {
        captureSession.stopRunning()
    }
}