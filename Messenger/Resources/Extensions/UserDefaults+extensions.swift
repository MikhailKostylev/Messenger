import Foundation

extension UserDefaults {
    
    static func login() {
        standard.set(true, forKey: Keys.isLoggedIn.rawValue)
    }
    
    static func isLoggedIn() -> Bool {
        return standard.bool(forKey: Keys.isLoggedIn.rawValue)
    }
}
