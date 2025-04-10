import Foundation

class OAuth2TokenStorage {
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "auth_token")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "auth_token")
        }
    }
}
