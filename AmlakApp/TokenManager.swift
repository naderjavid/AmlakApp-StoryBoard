import Foundation

protocol TokenManagerProtocol {
    func getAccessToken() -> String?
    func saveAccessToken(_ token: String)
    func clearAccessToken()
}

class TokenManager: TokenManagerProtocol {
    static let shared = TokenManager()
    private let userDefaults = UserDefaults.standard
    private let accessTokenKey = "AccessToken"

    init() {
        
    }
    
    func getAccessToken() -> String? {
        return userDefaults.string(forKey: accessTokenKey)
    }

    func saveAccessToken(_ token: String) {
        userDefaults.set(token, forKey: accessTokenKey)
    }

    func clearAccessToken() {
        userDefaults.removeObject(forKey: accessTokenKey)
    }
}
