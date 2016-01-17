import Foundation
import UIKit

import CleanroomLogger
import Eureka
import Motif

class UserFormViewController: FormViewController {
    var userManager: UserManager!
    var theme: MTFTheme!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ViewControllerHolder.instance.setCurrentViewController(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var user = userManager.loadUser() ?? User()
        
        // TODO: I18N
        form +++ Section("Contact Info")
            <<< NameRow() {
                $0.title = "First Name"
                $0.value = user.firstName
            }
            .onChange { [weak self] row in
                user.firstName = row.value
                self?.userManager.saveUser(user)
            }
            .cellSetup { cell, row in
                self.theme.applyClass("FirstNameTitle", to: cell.titleLabel!)
                print(cell.titleLabel?.textColor)
            }
            <<< NameRow() {
                $0.title = "Last Name"
                $0.value = user.lastName
            }
            .onChange { [weak self] row in
                user.lastName = row.value
                self?.userManager.saveUser(user)
            }
            <<< PhoneRow() {
                $0.title = "Phone Number"
                $0.value = user.phoneNumber
            }
            .onChange { [weak self] row in
                user.phoneNumber = row.value
                self?.userManager.saveUser(user)
            }
        
        form +++ Section("Social")
            <<< FacebookAccountRow().onChange { row in
                Log.info?.message("Setting Facebookd ID to \(row.value)")
                user.facebookId = row.value
                self.userManager.saveUser(user)
            }
            <<< AccountRow() {
                $0.title = "Snapchat"
                $0.value = user.snapchatUsername
            }
            .onChange { [weak self] row in
                user.snapchatUsername = row.value
                self?.userManager.saveUser(user)
            }
            <<< TwitterRow() {
                $0.title = "Twitter"
                $0.value = user.twitterHandle
            }
            .onChange { [weak self] row in
                user.twitterHandle = row.value
                self?.userManager.saveUser(user)
            }
    }
}