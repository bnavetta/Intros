//import Foundation
//import RxSwift
//import RxCocoa
//import Action
//import CleanroomLogger
//
//protocol PrepareIntroductionViewModel {
//    var shareables: [Shareable] { get }
//    func introduceButtonCommand() -> CocoaAction
//}
//
//// as the main vc, subclass UIPageViewController to swipe vertically between the
//// PrepareIntroductionViewController and the QR code vc
//// Keep the view model in the main vc and treat the two page vcs as view implementation details
//// have a private Variable in the view model holding the proto that's updated when any of the Shareables change (combine either
//// the Variables or their observables), have a PublishSubject to expose a UIImage as an Observable that's written to
//// with the new QR code whenever the proto changes (could also have the scale as a variable that triggers changing the image)
//// Whenever the image changes, rebind it in the QR code view controller, and bind the Shareables in a table view as before
//// The main vc can get the children vcs as @IBOutlets via the storyboard
//
//class PrepareIntroductionViewModelType: PrepareIntroductionViewModel {
//    // TODO: initialize from user defaults
//    // TODO: only ask for things the user has set up
//    
//    let shareName = Shareable(name: "Name")
//    let sharePhoneNumber = Shareable(name: "Phone Number")
//    let shareFacebook = Shareable(name: "Facebook")
//    let shareTwitter = Shareable(name: "Twitter")
//    let shareSnapchat = Shareable(name: "Snapchat")
//    
//    let userManager: UserManager
//    
//    var shareables: [Shareable]
//    
//    init(userManager: UserManager) {
//        self.userManager = userManager
//        self.shareables = [shareName, sharePhoneNumber, shareFacebook, shareTwitter, shareSnapchat]
//    }
//    
//    func introduceButtonCommand() -> CocoaAction {
//        let enabled = Observable.just(true);
//        
//        return CocoaAction(enabledIf: enabled) { [weak self] _ in
//            guard let me = self else {
//                return .empty()
//            }
//            
//            let userObservable = me.userManager.loadUser(ConcurrentDispatchQueueScheduler.backgroundInstance)
//            return userObservable.map { user -> BNIUser in
//                let proto = BNIUser()
//                if me.shareName.shouldShare.value {
//                    proto.firstName = user.firstName
//                    proto.lastName = user.lastName
//                }
//                
//                if me.sharePhoneNumber.shouldShare.value {
//                    proto.phoneNumber = user.phoneNumber
//                }
//                
//                if me.shareFacebook.shouldShare.value {
//                    proto.facebook = user.facebookId
//                }
//                
//                if me.shareTwitter.shouldShare.value {
//                    proto.twitter = user.twitterHandle
//                }
//                
//                if me.shareSnapchat.shouldShare.value {
//                    proto.snapchat = user.snapchatUsername
//                }
//            
//                return proto
//            }
//            .doOnNext { proto in
//                
//            }
//            .map(void)
//        }
//    }
//}