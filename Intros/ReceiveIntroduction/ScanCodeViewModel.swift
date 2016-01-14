import Foundation
import AVFoundation

import RxSwift
import RxCocoa
import Action
import Motif
import CleanroomLogger

protocol ScanCodeViewModelType {
    func scanForCode() -> Observable<ImportInformationViewModelType>
    
    // Maybe a bit un-MVVM, but it's how the API works
    var previewLayer: AVCaptureVideoPreviewLayer { get }
    
    var latestCodeBounds: Driver<CGRect> { get }
}

class ScanCodeViewModel: ScanCodeViewModelType {
    private let capture: QRCodeCapturer
    private let shareService: ShareServiceType
    private let theme: MTFTheme
    
    let previewLayer: AVCaptureVideoPreviewLayer
    
    var latestCodeBounds: Driver<CGRect> {
        return capture.qrCode
            .map { self.previewLayer.transformedMetadataObjectForMetadataObject($0).bounds }
            .asDriver(onErrorJustReturn: CGRectZero)
    }
    
    init(shareService: ShareServiceType, theme: MTFTheme) {
        self.shareService = shareService
        self.theme = theme
        capture = QRCodeCapturer(queue: dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0))
        previewLayer = AVCaptureVideoPreviewLayer(session: capture.captureSession)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    }
    
    func scanForCode() -> Observable<ImportInformationViewModelType> {
        do {
            try capture.startCapture()
        }
        catch let e {
            if AppSetup.simulator {
                Log.warning?.message("Camera not available on simulator")
                return Observable.just(ImportInformationViewModel(user: User.testInstance, shareService: self.shareService, theme: self.theme))
            }
            else {
                return Observable.error(e)
            }
        }
        
        return capture.qrCode.observeOn(MainScheduler.instance).map { metadataObject throws -> User in
            let data = metadataObject.stringValue.dataUsingEncoding(NSUTF8StringEncoding)!
            let user = User.fromProto(try BNIUser.parseData(data))
            
            Log.info?.message("Scanned user: \(user)")
            self.capture.stopCapture()
            return user
        }
        .doOnError { error in
            Log.error?.message("Error decoding user: \(error)")
        }
        .debug()
        .take(1)
            .map { user in return ImportInformationViewModel(user: user, shareService: self.shareService, theme: self.theme) }
    }
}