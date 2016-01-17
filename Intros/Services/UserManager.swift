import Foundation

import FileKit
import CleanroomLogger

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
    func loadUser() -> User?
    func saveUser(user: User) -> Bool
}

final class UserManagerImpl: UserManager {
    private let userFilePath = applicationSupport() + "user.dat";
    
    private var userFile: DataFile {
        return DataFile(path: userFilePath);
    }
    
    func loadUser() -> User? {
        do {
            let data = try self.userFile.read()
            let userProto = try BNIUser.parseData(data)
            return User.fromProto(userProto)
        }
        catch let e {
            Log.error?.message("Error loading user: \(e)")
            return nil
        }
    }
    
    func saveUser(user: User) -> Bool {
        do {
            try self.userFilePath.parent.createDirectory(withIntermediateDirectories: true)
            let data = user.toProto().data()!
            try data |> self.userFile
            return true
        }
        catch let e {
            Log.error?.message("Error saving user: \(e)")
            return false
        }
    }
}