import Foundation
import Prephirences

enum Preference: String {
    case ShareName
    case SharePhoneNumber
    case ShareFacebook
    case ShareTwitter
    case ShareSnapchat
}

extension PreferencesType {
    subscript(key: Preference) -> AnyObject? {
        return self[key.rawValue]
    }
    
    func hasObjectForKey(key: Preference) -> Bool {
        return hasObjectForKey(key.rawValue)
    }
    
    func boolForKey(key: Preference) -> Bool {
        return boolForKey(key.rawValue)
    }
}

extension MutablePreferencesType {
    subscript(key: Preference) -> AnyObject? {
        get {
            return self[key.rawValue]
        }
        set {
            if newValue == nil {
                removeObjectForKey(key.rawValue)
            }
            else {
                self[key.rawValue] = newValue
            }
        }
    }
    
    func setBool(value: Bool, forKey key: Preference) {
        setBool(value, forKey: key.rawValue)
    }
}

func setDefaultPreferences(prefs: MutablePreferencesType) {
    for sharePref in [Preference.ShareName, Preference.SharePhoneNumber, Preference.ShareFacebook, Preference.ShareSnapchat, Preference.ShareTwitter] {
        if !prefs.hasObjectForKey(sharePref) {
            prefs.setBool(true, forKey: sharePref)
        }
    }
}
