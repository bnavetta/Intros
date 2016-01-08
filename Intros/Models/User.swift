import Foundation

struct User {
    let firstName: String
    let lastName: String
    
    let phoneNumber: String
    
    let facebookId: String
    let snapchatUsername: String
    let twitterHandle: String
    
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
}