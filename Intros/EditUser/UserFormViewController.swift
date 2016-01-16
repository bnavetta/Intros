import Foundation
import UIKit

import Eureka

class UserFormViewController: FormViewController {
    var userManager: UserManager!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ViewControllerHolder.instance.setCurrentViewController(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var user = (try? userManager.loadUserSync()) ?? User(firstName: "", lastName: "", phoneNumber: "", facebookId: "", snapchatUsername: "", twitterHandle: "")
        
        // TODO: I18N
        form +++ Section("Contact Info")
            <<< NameRow() {
                $0.title = "First Name"
                $0.value = user.firstName
            }
            .onChange { [weak self] row in
//                user.firstName = row.value
//                do {
//                    try self?.userManager.saveUserSync(user)
//                }
            }
            <<< NameRow() {
                $0.title = "Last Name"
                $0.value = user.lastName
            }
            <<< PhoneRow() {
                $0.title = "Phone Number"
                $0.value = user.phoneNumber
            }
        
        form +++ Section("Social")
            <<< AccountRow() {
                $0.title = "Snapchat"
                $0.value = user.snapchatUsername
            }
            <<< TwitterRow() {
                $0.title = "Twitter"
                $0.value = user.twitterHandle
            }
    }
}