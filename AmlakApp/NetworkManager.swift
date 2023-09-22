import Foundation
var currentUser: User? = NetworkManager.shared.getUser();

enum NetworkError: Error {
    case invalidResponse
    case requestFailed
    case invalidData
    case invalidURL
    case noData
    // Add more cases as needed
}

class NetworkManager {
    
    private init() {}

    static let shared = NetworkManager()

    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let urlString = "\(BASE_URL)/connect/token"
        let parameters = [
            "grant_type": "password",
            "scope": "offline_access Amlak",
            "username": username,
            "password": password,
            "client_id": "Amlak_App"
        ]

        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyString = parameters.map { "\($0)=\($1)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print(response.debugDescription)
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print(responseString)
                    let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                    if let accessToken = json?["access_token"] as? String,
                        let refreshToken = json?["refresh_token"] as? String,
                        let expiresIn = json?["expires_in"] as? Int {

                        currentUser = User(username: username,
                                        accessToken: accessToken,
                                        refreshToken: refreshToken,
                                        accessTokenExpirationDate: Date().addingTimeInterval(TimeInterval(expiresIn)))
                        self.saveUser(currentUser!) // Save user information
                        completion(.success(currentUser!))
                    }

                }
            }
        }
        task.resume()
    }

    func refreshToken(completion: @escaping (Result<User, Error>) -> Void) {
        if let user = NetworkManager.shared.getUser() {
            
            let refreshToken = user.refreshToken
            let username = user.username

            let urlString = "\(BASE_URL)/connect/token"
            let parameters = [
                "grant_type": "refresh_token",
                "username": username,
                "client_id": "Amlak_App",
                "refresh_token": refreshToken
            ]

            var request = URLRequest(url: URL(string: urlString)!)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            let bodyString = parameters.map { "\($0)=\($1)" }.joined(separator: "&")
            request.httpBody = bodyString.data(using: .utf8)

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(NetworkError.invalidResponse))
                    return
                }
                
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let error = json["error"] as? String {
                        completion(.failure(NSError(domain: "refreshtoken", code: 2, userInfo: [NSLocalizedDescriptionKey: error])))

                    }
                    else {
                        
                        if let newAccessToken = json["access_token"] as? String,
                           let refreshToken = json["refresh_token"] as? String,
                           let expiresIn = json["expires_in"] as? Int {
                            currentUser = User(
                                username: username,
                                accessToken: newAccessToken,
                                refreshToken: refreshToken,
                                accessTokenExpirationDate: Date().addingTimeInterval(TimeInterval(expiresIn))
                            )
                            self.saveUser(user)
                            completion(.success(user))
                        }
                    }
                    
                } else {
                    completion(.failure(NSError(domain: "refreshtoken", code: 1, userInfo: nil)))
                }
            }
            task.resume()
        }
    }

    private func saveUser(_ user: User) {
        let userDefaults = UserDefaults.standard
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(user) {
            userDefaults.set(encodedData, forKey: "user")
        }
    }

    func getUser() -> User? {
        let userDefaults = UserDefaults.standard
        let decoder = JSONDecoder()
        if let userData = userDefaults.data(forKey: "user"),
            let user = try? decoder.decode(User.self, from: userData) {
            return user
        }
        return nil
    }
    func logout() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "user")
    }

}

