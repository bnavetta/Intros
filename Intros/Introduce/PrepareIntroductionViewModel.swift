import Foundation
import RxSwift
import RxCocoa
import Action
import CleanroomLogger

// Some bit of information that the user might want to share with their new friends
struct Shareable {
    let name: String
    let shouldShare: Variable<Bool>
    
    init(name: String) {
        self.name = name
        self.shouldShare = Variable(true)
    }
}

protocol PrepareIntroductionViewModel {
    var shareables: [Shareable] { get }
    func introduceButtonCommand() -> CocoaAction
}

class PrepareIntroductionViewModelType: PrepareIntroductionViewModel {
    // TODO: initialize from user defaults
    // TODO: only ask for things the user has set up
    
    let shareName = Shareable(name: "Name")
    let sharePhoneNumber = Shareable(name: "Phone Number")
    let shareFacebook = Shareable(name: "Facebook")
    let shareTwitter = Shareable(name: "Twitter")
    let shareSnapchat = Shareable(name: "Snapchat")
    
    var shareables: [Shareable]
    
    init() {
        self.shareables = [shareName, sharePhoneNumber, shareFacebook, shareTwitter, shareSnapchat]
    }
    
    func introduceButtonCommand() -> CocoaAction {
        let enabled = Observable.just(true);
        
        return CocoaAction(enabledIf: enabled) { [weak self] _ in
            Log.info?.message("Would route to PresentIntroCode just about now");
            return .empty();
        };
    }
}