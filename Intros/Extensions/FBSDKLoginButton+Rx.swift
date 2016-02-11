import Foundation
import UIKit

import FBSDKLoginKit
import RxSwift
import RxCocoa

class RxFBSDKLoginButtonDelegate: DelegateProxy, FBSDKLoginButtonDelegate, DelegateProxyType {
    
    let loginSubject = PublishSubject<FBSDKLoginManagerLoginResult>()
    let logoutSubject = PublishSubject<Void>()
    
    class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        return (object as! FBSDKLoginButton).delegate
    }
    
    static func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        (object as! FBSDKLoginButton).delegate = (delegate as? FBSDKLoginButtonDelegate)
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if let error = error {
            loginSubject.onError(error)
        }
        else {
            loginSubject.onNext(result)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        logoutSubject.onNext(())
    }
}

extension FBSDKLoginButton {
    public var rx_delegate: DelegateProxy {
        return proxyForObject(RxFBSDKLoginButtonDelegate.self, self)
    }
    
    public var rx_login: ControlEvent<FBSDKLoginManagerLoginResult> {
        return ControlEvent(events: (rx_delegate as! RxFBSDKLoginButtonDelegate).loginSubject)
    }
    
    public var rx_logout: ControlEvent<Void> {
        return ControlEvent(events: (rx_delegate as! RxFBSDKLoginButtonDelegate).logoutSubject)
    }
}