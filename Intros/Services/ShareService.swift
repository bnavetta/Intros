import Foundation
import Contacts
import ContactsUI

import RxSwift

protocol ShareServiceType {
    func shareContact(user: User) -> Observable<Void>
    func shareFacebook(user: User)
    func shareSnapchat(user: User)
    func shareTwitter(user: User)
}

class ShareService: ShareServiceType {
    private let contactStore = CNContactStore()
    
    // https://stackoverflow.com/questions/15625447/ios-add-contact-into-contacts
    func shareContact(user: User) -> Observable<Void> {
        let contact = CNMutableContact()
        
        if let firstName = user.firstName {
            contact.givenName = firstName
        }
        
        if let lastName = user.lastName {
            contact.familyName = lastName
        }
        
        if let phoneNumber = user.phoneNumber {
            contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: phoneNumber))]
        }
        
        let controller = CNContactViewController(forNewContact: contact)
        controller.contactStore = self.contactStore
        
        ViewControllerHolder.instance.pushViewcontroller(controller, animated: true)
        
        return controller.rx_completed
            .map { _ in
                ViewControllerHolder.instance.popViewController(true)
            }
            .take(1)
    }
    
    func shareFacebook(user: User) {
        if let facebookId = user.facebookId {
            openURL("fb://profile?app_scoped_user_id=\(facebookId)")
        }
    }
    
    func shareTwitter(user: User) {
        if let twitterHandle = user.twitterHandle {
            openURL("twitter://user?screen_name=\(twitterHandle)")
        }
    }
    
    func shareSnapchat(user: User) {
        if let snapchatUsername = user.snapchatUsername {
            openURL("snapchat://?u=\(snapchatUsername)")
        }
    }
    
    private func openURL(url: String) -> Bool {
        guard let url = NSURL(string: url) else {
            return false
        }
        
        if UIApplication.sharedApplication().canOpenURL(url) {
            return UIApplication.sharedApplication().openURL(url)
        }
        return false
    }
}