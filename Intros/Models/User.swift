import Foundation

enum InformationType: String {
    case Name = "Name"
    case PhoneNumber = "PhoneNumber"
    case Facebook = "Facebook"
    case Twitter = "Twitter"
    case Snapchat = "Snapchat"
    
    var title: String {
        return NSLocalizedString(rawValue, comment: "")
    }
    
    static let values: [InformationType] = [.Name, .PhoneNumber, .Facebook, .Twitter, .Snapchat]
}

struct User {
    var firstName: String? {
        didSet {
            if firstName?.isEmpty ?? false {
                firstName = nil
            }
        }
    }
    
    var lastName: String? {
        didSet {
            if lastName?.isEmpty ?? false {
                lastName = nil
            }
        }
    }
    
    var phoneNumber: String? {
        didSet {
            if phoneNumber?.isEmpty ?? false {
                phoneNumber = nil
            }
        }
    }
    
    var facebookId: String? {
        didSet {
            if facebookId?.isEmpty ?? false {
                facebookId = nil
            }
        }
    }
    var snapchatUsername: String? {
        didSet {
            if snapchatUsername?.isEmpty ?? false {
                snapchatUsername = nil
            }
        }
    }
    var twitterHandle: String? {
        didSet {
            if twitterHandle?.isEmpty ?? false {
                twitterHandle = nil
            }
        }
    }
    
    static var testInstance = User(firstName: "Ben", lastName: "Navetta", phoneNumber: "9783023343", facebookId: "100001646049061", snapchatUsername: "ben.navetta", twitterHandle: "BenNavetta")
    
    static func fromProto(proto: BNIUser) -> User {
        var user = User()
        // make sure didSet checks run
        user.firstName = proto.firstName
        user.lastName = proto.lastName
        user.phoneNumber = proto.phoneNumber
        user.facebookId = proto.facebook
        user.snapchatUsername = proto.snapchat
        user.twitterHandle = proto.twitter
        return user
    }
    
    func toProto() -> BNIUser {
        let proto = BNIUser();
        proto.firstName = firstName;
        proto.lastName = lastName;
        proto.phoneNumber = phoneNumber;
        proto.facebook = facebookId;
        proto.snapchat = snapchatUsername;
        proto.twitter = twitterHandle;
        return proto;
    }
}