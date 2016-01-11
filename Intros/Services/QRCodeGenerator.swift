import Foundation
import UIKit
import RxSwift
import CleanroomLogger

let QRCodeErrorDomain = "com.bennavetta.qr";

// https://github.com/ShinobiControls/iOS7-day-by-day/blob/master/15-core-image-filters/15-core-image-filters.md

class QRCodeGenerator {
    
    class func generateCode(data: NSData, scale: CGFloat, scheduler: SchedulerType) -> Observable<UIImage> {
        return Observable.create { observer in
            return scheduler.schedule(data) { data in
                if let code = createQRCode(data) {
                    let image = createNonInterpolatedUIImageFromCIImage(code, scale: scale)
                    observer.onNext(image)
                    observer.onCompleted()
                }
                else {
                    observer.onError(NSError(domain: QRCodeErrorDomain, code: 0, userInfo: ["data": data]))
                }
                return NopDisposable.instance
            }
        }
    }
    
    private class func createQRCode(data: NSData) -> CIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            Log.warning?.message("Could not instantiate CIQRCodeGenerator filter")
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        return filter.outputImage
    }
    
    private class func createNonInterpolatedUIImageFromCIImage(image: CIImage, scale: CGFloat) -> UIImage {
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