import Foundation

class AppSetup {
    static var debug: Bool {
        if let debugValue = NSProcessInfo.processInfo().environment["DEBUG"] {
            return debugValue == "YES"
        }
        return false
    }
    
    static var test: Bool {
        return NSClassFromString("XCTest") != nil
    }
    
    static var devMode: Bool {
        return debug || test
    }
}