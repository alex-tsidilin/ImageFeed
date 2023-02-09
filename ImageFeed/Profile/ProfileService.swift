
import Foundation

final class ProfileService {
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    static let shared = ProfileService()
    
    func fetchProfile(token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastToken == token { return }
        task?.cancel()
        lastToken = token
        
        let request = requestUserData(token: token)

        let task = urlSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                
                guard let data = data else { return }

                do {
                    let json = try JSONDecoder().decode(ProfileResult.self, from: data)
                    let profile = Profile(
                        username: json.username,
                        name: "\(json.first_name) \(json.last_name)",
                        loginName: "@\(json.username)",
                        bio: json.bio
                    )
                    completion(.success(profile))
                } catch let error {
                    completion(.failure(error))
                }
                
                self.task = nil
                if error != nil {
                    self.lastToken = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    func requestUserData(token: String) -> URLRequest {

        let unsplashGetUserDataURLString = Constants.defaultBaseURLString + "me"
        
        guard let url = URL(string: unsplashGetUserDataURLString)
            else { fatalError("Failed to create URL") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("создан запрос на получение данных о пользователе \(request)")
        return request
    }

    struct ProfileResult: Codable {
        
        let username: String
        let first_name: String
        let last_name: String
        let bio: String?
        
        private enum CodingKeys: String, CodingKey {
            case username = "username"
            case first_name = "first_name"
            case last_name = "last_name"
            case bio = "bio"
        }
    }

    struct Profile {
        let username: String
        let name: String
        let loginName: String
        let bio: String?
    }

}
