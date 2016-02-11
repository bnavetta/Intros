import Foundation
import UIKit

import Eureka
import FBSDKLoginKit
import CleanroomLogger

public class FacebookAccountCell: Cell<String>, CellType {
    @IBOutlet
    weak var loginButton: FBSDKLoginButton!
    
    public override func setup() {
        row.title = nil
        super.setup()
        selectionStyle = .None
        
        loginButton.rx_login.subscribeNext { result in
            if !result.isCancelled {
                
//                FBSDKAccessToken.setCurrentAccessToken(result.token)
                
                self.row.value = result.token.userID
                
//                let url = "fb://profile?app_scoped_user_id=\(result.token.userID)"
//                print(url)
//                UIApplication.sharedApplication().openURL(NSURL(string: url)!)
//                
//                Facebook.requestProfile().subscribeNext { profile in
//                    Log.info?.message("Facebook profile")
//                    Log.info?.value(profile)
//                }
//                .addDisposableTo(self.rx_disposeBag)
            }
        }
        .addDisposableTo(rx_disposeBag)
        
        loginButton.rx_logout.subscribeNext { _ in
            self.row.value = nil
        }
        .addDisposableTo(rx_disposeBag)
    }
}

public final class FacebookAccountRow: Row<String, FacebookAccountCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil // TODO: lookup username?
        cellProvider = CellProvider<FacebookAccountCell>(nibName: "FacebookAccountCell")
    }
}