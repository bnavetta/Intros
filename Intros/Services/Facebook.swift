import Foundation

import FBSDKCoreKit
import FBSDKLoginKit
import RxSwift

class RxFacebookLoginDelegate: NSObject, FBSDKLoginButtonDelegate {
    
    private let resultSubject = PublishSubject<FBSDKLoginManagerLoginResult>()
    private let logoutSubject = PublishSubject<()>()
    
    var rx_result: Observable<FBSDKLoginManagerLoginResult> {
        return resultSubject
    }
    
    var rx_logout: Observable<()> {
        return logoutSubject
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if error == nil {
            resultSubject.onNext(result)
        }
        else {
            resultSubject.onError(error)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        logoutSubject.onNext(())
    }
}

struct Facebook {
    static func requestProfile(fields: [String] = ["id", "name"]) -> Observable<AnyObject> {
        return Observable.create { observer in
            if let _ = FBSDKAccessToken.currentAccessToken() {
                let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": fields])
                let conn = request.startWithCompletionHandler { connection, result, error in
                    if error == nil {
                        observer.onNext(result)
                    }
                    else {
                        observer.onError(error)
                        observer.onCompleted()
                    }
                }
                
                return AnonymousDisposable {
                    conn.cancel()
                }
            }
            else {
                observer.onError(NSError(domain: "con.bennavetta.Intros.Facebook", code: 1, userInfo: [NSLocalizedDescriptionKey: "Not logged in"]))
                observer.onCompleted()
                return NopDisposable.instance
            }
        }
    }
}