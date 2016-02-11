import Foundation

import FBSDKCoreKit
import FBSDKLoginKit
import RxSwift

struct Facebook {
    static func requestProfile(fields: [String] = ["id", "name"]) -> Observable<AnyObject> {
        return Observable.create { observer in
            if let _ = FBSDKAccessToken.currentAccessToken() {
                let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": fields.joinWithSeparator(",")])
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