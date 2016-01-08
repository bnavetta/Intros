import Foundation
import FileKit
import RxSwift

private func applicationSupport() -> Path {
    return NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        .map({ Path($0) })[0];
}

extension BNIUser {
    class func parseData(data: NSData) throws -> BNIUser {
        var error: NSError?;
        let user = parseFromData(data, error: &error);
        if let error = error {
            throw error;
        }
        return user;
    }
}

final class UserManager {
    private let userFilePath = applicationSupport() + "user.dat";
    
    private var userFile: DataFile {
        return DataFile(path: userFilePath);
    }
    
    func loadUser() -> Observable<User> {
        return Observable.create { observer in
            do {
                let data = try self.userFile.read();
                let userProto = try BNIUser.parseData(data);
                observer.onNext(User.fromProto(userProto));
            }
            catch let e {
                observer.onError(e);
            }
            
            return NopDisposable.instance;
        };
    }
    
    func saveUser(user: User) -> Observable<Void> {
        return Observable.create { observer in
            do {
                let data = user.toProto().data()!;
                try data |> self.userFile;
                observer.onNext(());
            }
            catch let e {
                observer.onError(e);
            }
            
            return NopDisposable.instance;
        }
    }
}