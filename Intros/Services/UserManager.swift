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

protocol UserManager {
    func loadUser(scheduler: SchedulerType) -> Observable<User>
    func saveUser(user: User, scheduler: SchedulerType) -> Observable<()>
    
    func loadUserSync() throws -> User
    func saveUserSync(user: User) throws
}

final class UserManagerImpl: UserManager {
    private let userFilePath = applicationSupport() + "user.dat";
    
    private var userFile: DataFile {
        return DataFile(path: userFilePath);
    }
    
    func loadUserSync() throws -> User {
        let data = try self.userFile.read()
        let userProto = try BNIUser.parseData(data)
        return User.fromProto(userProto)
    }
    
    func saveUserSync(user: User) throws {
        try self.userFilePath.parent.createDirectory(withIntermediateDirectories: true)
        let data = user.toProto().data()!
        try data |> self.userFile
    }
    
    func loadUser(scheduler: SchedulerType) -> Observable<User> {
        return Observable.create { observer in
            return scheduler.schedule(()) {_ in
                do {
                    observer.onNext(try self.loadUserSync())
                    observer.onCompleted()
                }
                catch let e {
                    observer.onError(e)
                }
                
                return NopDisposable.instance
            }
        }
        .observeOn(MainScheduler.instance)
    }
    
    func saveUser(user: User, scheduler: SchedulerType) -> Observable<Void> {
        return Observable.create { observer in
            return scheduler.schedule(user) { user in
                do {
                    try self.saveUserSync(user)
                    observer.onNext(())
                    observer.onCompleted()
                }
                catch let e {
                    observer.onError(e)
                }
                
                return NopDisposable.instance
            }
        }
        .observeOn(MainScheduler.instance)
    }
}