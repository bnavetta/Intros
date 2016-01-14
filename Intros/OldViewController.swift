//
//  ViewController.swift
//  Intros
//
//  Created by Ben Navetta on 1/7/16.
//  Copyright © 2016 Ben Navetta. All rights reserved.
//

import UIKit

class OldViewController: UIViewController {

    @IBOutlet
    weak var imageView: UIImageView!
    
    let user: BNIUser = {
        let myUser = BNIUser();
        myUser.firstName = "Ben";
        myUser.lastName = "Navetta";
        myUser.phoneNumber = "9783023343";
        myUser.facebook = "100001646049061";
        myUser.snapchat = "ben.navetta";
        myUser.twitter = "BenNavetta";
        return myUser;
    }();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let qrCode = createQRCode(user) {
            imageView.image = createNonInterpolatedUIImageFromCIImage(qrCode, scale: 2 * UIScreen.mainScreen().scale);
            imageView.sizeToFit();
        }
    }

    @IBAction
    func startScanning(sender: AnyObject) {
        do {
            let scannerVC = try QRCaptureViewController.withDefaultDevice();
            presentViewController(scannerVC, animated: true, completion: nil);
        }
        catch let e {
            print(e);
        }
    }
    
    // https://github.com/ShinobiControls/iOS7-day-by-day/blob/master/15-core-image-filters/15-core-image-filters.md

    func createQRCode(user: BNIUser) -> CIImage? {
        guard let data = user.data() else {
            return nil;
        }
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil;
        }
        
        filter.setValue(data, forKey: "inputMessage");
        filter.setValue("H", forKey: "inputCorrectionLevel");
        
        return filter.outputImage;
    }
    
    func createNonInterpolatedUIImageFromCIImage(image: CIImage, scale: CGFloat) -> UIImage {
        let cgImage = CIContext(options: nil).createCGImage(image, fromRect: image.extent);
        
        UIGraphicsBeginImageContext(CGSize(width: image.extent.size.width * scale, height: image.extent.size.height * scale));
        let context = UIGraphicsGetCurrentContext();
        
        defer {
            UIGraphicsEndImageContext();
        }
        
        // The image is pixel-correct, so don't interpolate
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.None);
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
        
        return UIGraphicsGetImageFromCurrentImageContext();
    }
}

