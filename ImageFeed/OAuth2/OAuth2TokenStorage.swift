import Foundation
import SwiftKeychainWrapper

class OAuth2TokenStorage {
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: storageKey)
        }
        set {
            if let newValue {
                KeychainWrapper.standard.set(newValue, forKey: storageKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: storageKey)
            }
        }
    }
    static let shared = OAuth2TokenStorage()
    private let storageKey = "Auth token"

    private init() { }
}
