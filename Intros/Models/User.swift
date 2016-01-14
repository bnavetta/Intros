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
    let firstName: String
    let lastName: String
    
    let phoneNumber: String
    
    let facebookId: String
    let snapchatUsername: String
    let twitterHandle: String
    
    static var testInstance = User(firstName: "Ben", lastName: "Navetta", phoneNumber: "9783023343", facebookId: "100001646049061", snapchatUsername: "ben.navetta", twitterHandle: "BenNavetta")
    
    static func fromProto(proto: BNIUser) -> User {
        return User(firstName: proto.firstName,
            lastName: proto.lastName,
            phoneNumber: proto.phoneNumber,
            facebookId: proto.facebook,
            snapchatUsername: proto.snapchat,
            twitterHandle: proto.twitter);
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
    
    func hasInfo(type: InformationType) -> Bool {
        switch type {
        case .Name:
            return firstName != "" && lastName != ""
        case .PhoneNumber:
            return phoneNumber != ""
        case .Facebook:
            return facebookId != ""
        case .Snapchat:
            return snapchatUsername != ""
        case .Twitter:
            return twitterHandle != ""
        }
    }
}