import Foundation

import RxSwift
import RxCocoa
import Action
import CleanroomLogger
import Prephirences

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
    
    init(type: InformationType, share: Bool) {
        self.type = type
        self.shareChecked = Variable(share)
        self.enabled = Variable(true)
    }
}

protocol IntroduceViewModelType {
    var qrCodeImage: Driver<UIImage> { get }
    
    var shareInfoCount: Int { get }
    
    func reload()
    
    func shareInfoAtIndexPath(indexPath: NSIndexPath) -> ShareInfoViewModel
    
    func setQrCodeScale(scale: CGFloat)
}

class IntroduceViewModel: NSObject, IntroduceViewModelType {
    private let qrCodeSubject: BehaviorSubject<UIImage> = BehaviorSubject(value: UIImage(named: "empty")!)
    private let qrCodeScale: Variable<CGFloat> = Variable(2 * UIScreen.mainScreen().scale)
    
    private var user: User!
    
    private let userManager: UserManager
    private let preferences: MutablePreferencesType
    
    private let nameInfo: ShareInfoViewModel
    private let phoneNumberInfo: ShareInfoViewModel
    private let facebookInfo: ShareInfoViewModel
    private let twitterInfo: ShareInfoViewModel
    private let snapchatInfo: ShareInfoViewModel
    
    private let allInfo: [ShareInfoViewModel]
    
    var qrCodeImage: Driver<UIImage> {
        return qrCodeSubject.asDriver(onErrorJustReturn: UIImage(named: "empty")!)
    }
    
    init(userManager: UserManager, preferences: MutablePreferencesType) {
        self.userManager = userManager
        self.preferences = preferences
        
        self.nameInfo = ShareInfoViewModel(type: .Name, share: preferences.boolForKey(.ShareName))
        self.phoneNumberInfo = ShareInfoViewModel(type: .PhoneNumber, share: preferences.boolForKey(.SharePhoneNumber))
        self.facebookInfo = ShareInfoViewModel(type: .Facebook, share: preferences.boolForKey(.ShareFacebook))
        self.twitterInfo = ShareInfoViewModel(type: .Twitter, share: preferences.boolForKey(.ShareTwitter))
        self.snapchatInfo = ShareInfoViewModel(type: .Snapchat, share: preferences.boolForKey(.ShareSnapchat))
        
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
        reload()
        // Instead of making shareables a variable so I can filter,
        // show all bits of information and just disable the checkbox on ones without
        // info (add another Variable<Bool> to Shareable)
        
        nameInfo.shareChecked.asDriver().driveNext { checked in
            self.preferences.setBool(checked, forKey: .ShareName)
        }.addDisposableTo(rx_disposeBag)
        
        phoneNumberInfo.shareChecked.asDriver().driveNext { checked in
            self.preferences.setBool(checked, forKey: .SharePhoneNumber)
        }.addDisposableTo(rx_disposeBag)
        
        facebookInfo.shareChecked.asDriver().driveNext { checked in
            self.preferences.setBool(checked, forKey: .ShareFacebook)
        }.addDisposableTo(rx_disposeBag)
        
        twitterInfo.shareChecked.asDriver().driveNext { checked in
            self.preferences.setBool(checked, forKey: .ShareTwitter)
        }.addDisposableTo(rx_disposeBag)
        
        snapchatInfo.shareChecked.asDriver().driveNext { checked in
            self.preferences.setBool(checked, forKey: .ShareSnapchat)
        }.addDisposableTo(rx_disposeBag)
        
        Observable.combineLatest(Observable.of(nameInfo, phoneNumberInfo, facebookInfo, twitterInfo, snapchatInfo)
            .map({ $0.shareChecked.asObservable() })
            .merge(), qrCodeScale.asObservable()) {_, _ in return Void() }
            .subscribeNext { _ in
                self.updateCode()
            }
            .addDisposableTo(self.rx_disposeBag)
    }
    
    func reload() {
        self.user = userManager.loadUser()
        
        nameInfo.enabled.value = user.firstName != nil || user.lastName != nil
        phoneNumberInfo.enabled.value = user.phoneNumber != nil
        facebookInfo.enabled.value = user.facebookId != nil
        twitterInfo.enabled.value = user.twitterHandle != nil
        snapchatInfo.enabled.value = user.snapchatUsername != nil
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