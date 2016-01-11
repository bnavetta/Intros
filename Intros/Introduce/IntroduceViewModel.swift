import Foundation
import RxSwift
import RxCocoa
import Action
import CleanroomLogger

class ShareInfoViewModel {
    private let type: InformationType
    
    let shareChecked: Variable<Bool>
    let enabled: Variable<Bool>
    
    var name: String {
        return type.title
    }
    
    private var shouldShare: Bool {
        return shareChecked.value && enabled.value
    }
    
    init(type: InformationType) {
        self.type = type
        self.shareChecked = Variable(true)
        self.enabled = Variable(true)
    }
}

protocol IntroduceViewModelType {
    var qrCodeImage: Driver<UIImage> { get }
    
    var shareInfoCount: Int { get }
    
    func shareInfoAtIndexPath(indexPath: NSIndexPath) -> ShareInfoViewModel
    
    func setQrCodeScale(scale: CGFloat)
}

class IntroduceViewModel: NSObject, IntroduceViewModelType {
    private let qrCodeSubject: BehaviorSubject<UIImage> = BehaviorSubject(value: UIImage(named: "empty")!)
    private let qrCodeScale: Variable<CGFloat> = Variable(2 * UIScreen.mainScreen().scale)
    
    private var user: User!
    
    private let userManager: UserManager
    
    private let nameInfo = ShareInfoViewModel(type: .Name)
    private let phoneNumberInfo = ShareInfoViewModel(type: .PhoneNumber)
    private let facebookInfo = ShareInfoViewModel(type: .Facebook)
    private let twitterInfo = ShareInfoViewModel(type: .Twitter)
    private let snapchatInfo = ShareInfoViewModel(type: .Snapchat)
    
    private let allInfo: [ShareInfoViewModel]
    
    var qrCodeImage: Driver<UIImage> {
        return qrCodeSubject.asDriver(onErrorJustReturn: UIImage(named: "empty")!)
    }
    
    init(userManager: UserManager) {
        self.userManager = userManager
        self.allInfo = [nameInfo, phoneNumberInfo, facebookInfo, twitterInfo, snapchatInfo]
        super.init()
        initBindings()
    }
    
    var shareInfoCount: Int {
        return allInfo.count
    }
    
    func shareInfoAtIndexPath(indexPath: NSIndexPath) -> ShareInfoViewModel {
        return allInfo[indexPath.row]
    }
    
    func setQrCodeScale(scale: CGFloat) {
        qrCodeScale.value = scale
    }
    
    private func initBindings() {
        userManager.loadUser(ConcurrentDispatchQueueScheduler.backgroundInstance).subscribeNext { user in
            self.user = user
            
            // Instead of making shareables a variable so I can filter,
            // show all bits of information and just disable the checkbox on ones without 
            // info (add another Variable<Bool> to Shareable)
            
            self.nameInfo.enabled.value = user.hasInfo(.Name)
            self.phoneNumberInfo.enabled.value = user.hasInfo(.PhoneNumber)
            self.facebookInfo.enabled.value = user.hasInfo(.Facebook)
            self.twitterInfo.enabled.value = user.hasInfo(.Twitter)
            self.snapchatInfo.enabled.value = user.hasInfo(.Snapchat)
            
            Observable.combineLatest(Observable.of(self.nameInfo, self.phoneNumberInfo, self.facebookInfo, self.twitterInfo, self.snapchatInfo)
                .map({ $0.shareChecked.asObservable() })
                .merge(), self.qrCodeScale.asObservable()) {_, _ in return Void() }
                .subscribeNext { _ in
                    self.updateCode()
                }
                .addDisposableTo(self.rx_disposeBag)
        }
        .addDisposableTo(rx_disposeBag)
    }
    
    private func updateCode() {
        let proto = BNIUser()
        
        if nameInfo.shouldShare {
            proto.firstName = user.firstName
            proto.lastName = user.lastName
        }
        
        if phoneNumberInfo.shouldShare {
            proto.phoneNumber = user.phoneNumber
        }
        
        if facebookInfo.shouldShare {
            proto.facebook = user.facebookId
        }
        
        if twitterInfo.shouldShare {
            proto.twitter = user.twitterHandle
        }
        
        if snapchatInfo.shouldShare {
            proto.snapchat = user.snapchatUsername
        }
        
        Log.debug?.message("Generating QR code from \(proto)")
        
        QRCodeGenerator.generateCode(proto.data()!, scale: qrCodeScale.value, scheduler: ConcurrentDispatchQueueScheduler.backgroundInstance)
            .doOnError { error in
                Log.error?.message("Error generating QR code: \(error)")
            }
            .subscribeNext { image in
                Log.debug?.message("Generated QR code \(image)")
                self.qrCodeSubject.onNext(image)
            }
            .addDisposableTo(rx_disposeBag)
    }
}