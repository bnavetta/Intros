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
        contact.familyName = user.lastName
        contact.givenName = user.firstName
        contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: user.phoneNumber))]
        
        let controller = CNContactViewController(forNewContact: contact)
        controller.contactStore = self.contactStore
        
        ViewControllerHolder.instance.pushViewcontroller(controller, animated: true)
        
        return controller.rx_completed
            .map { _ in
                ViewControllerHolder.instance.popViewController(true)
            }
            .take(1)
//            .flatMap {_ in
//                return Observable<Void>.create { observer in
//                    ViewControllerHolder.instance.dismissViewController(true) {
//                        observer.onCompleted()
//                    }
//                }
//                
////                navigationController.dismissViewControllerAnimated(true, completion: nil)
////                ViewControllerHolder.instance.dismissViewController(true) {
////                    print("It went away?")
////                }
//            }
//            .take(1)
    }
    
    func shareFacebook(user: User) {
        openURL(NSURL(string: "fb://profile/\(user.facebookId)")!)
    }
    
    func shareTwitter(user: User) {
        openURL(NSURL(string: "twitter://user?screen_name=\(user.twitterHandle)")!)
    }
    
    func shareSnapchat(user: User) {
        openURL(NSURL(string: "snapchat://?u=\(user.snapchatUsername)")!)
    }
    
    private func openURL(url: NSURL) -> Bool {
        if UIApplication.sharedApplication().canOpenURL(url) {
            return UIApplication.sharedApplication().openURL(url)
        }
        return false
    }
}