import Foundation

struct User: Codable {
    var username: String
    var accessToken: String
    var refreshToken: String
    var accessTokenExpirationDate: Date // Add this property
}
