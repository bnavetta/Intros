//
//  QRCaptureViewController.swift
//  Intros
//
//  Created by Ben Navetta on 1/8/16.
//  Copyright © 2016 Ben Navetta. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

// http://www.appcoda.com/qr-code-reader-swift/

class QRCaptureViewController : UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    let captureSession = AVCaptureSession();
    let qrCodeFrameView = UIView();
    let videoPreviewLayer: AVCaptureVideoPreviewLayer;
    
    init(input: AVCaptureDeviceInput) {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
        
        captureSession.addInput(input);
        
        let captureMetadataOutput = AVCaptureMetadataOutput();
        captureSession.addOutput(captureMetadataOutput);
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode];
        
        super.init(nibName: nil, bundle: nil);
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue());
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func withDefaultDevice() throws -> QRCaptureViewController {
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo);
        
        let input = try AVCaptureDeviceInput(device: captureDevice);
        
        return QRCaptureViewController(input: input);
    }
    
    override func viewDidLoad() {
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        videoPreviewLayer.frame = view.layer.bounds;
        view.layer.addSublayer(videoPreviewLayer);
        
        qrCodeFrameView.layer.borderColor = UIColor.greenColor().CGColor;
        qrCodeFrameView.layer.borderWidth = 2;
        view.addSubview(qrCodeFrameView);
        view.bringSubviewToFront(qrCodeFrameView);
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView.frame = CGRectZero;
            return;
        }
        
        let metadataObj = metadataObjects.first! as! AVMetadataMachineReadableCodeObject;
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            let barCodeObject = videoPreviewLayer.transformedMetadataObjectForMetadataObject(metadataObj);
            qrCodeFrameView.frame = barCodeObject.bounds;
            
            if let data = metadataObj.stringValue {
                var error: NSError?;
                let user = BNIUser.parseFromData(data.dataUsingEncoding(NSUTF8StringEncoding)!, error: &error);
                
                var message: String;
                if let error = error {
                    message = error.description;
                }
                else {
                    message = user.description;
                }
                
                let alert = UIAlertController(title: "Scanned Code", message: message, preferredStyle: UIAlertControllerStyle.Alert);
                
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil);
                alert.addAction(okAction);
                
                self.presentViewController(alert, animated: true) {
                    self.dismissViewControllerAnimated(true, completion: nil);
                };
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        startCapture();
    }
    
    func startCapture() {
        captureSession.startRunning();
    }
}