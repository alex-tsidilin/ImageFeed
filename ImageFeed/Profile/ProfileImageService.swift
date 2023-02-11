
import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private (set) var avatarURL: String?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    private var lastUsername: String?
    private var profileImage: ProfileImage?
    
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    struct ProfileImage: Codable {
        let profileImage: ImageSize
        
        private enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }

    struct ImageSize: Codable {
        let small: String?
        
        private enum CodingKeys: String, CodingKey {
            case small = "small"
        }
    }
    
    func fetchProfileImageURL(username: String, token: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastToken == token { return }
        if lastUsername == username { return }
        task?.cancel()
        lastToken = token
        lastUsername = username
        
        let request = requestProfileImage(username: username, token: token)
                
        let task = urlSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {

                guard let data = data else { return }

                do {
                    let json = try JSONDecoder().decode(ProfileImage.self, from: data)

                    guard let profileImageURL = json.profileImage.small else { return }
                    self.avatarURL = profileImageURL
                    print("Получили ссылку на автарку \(profileImageURL)")

                    completion(.success(profileImageURL))
                    
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.DidChangeNotification,
                            object: self,
                            userInfo: ["URL": profileImageURL])
                
                } catch let error {
                    completion(.failure(error))
                }
                
                self.task = nil
                if error != nil {
                    self.lastToken = nil
                    self.lastUsername = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    func requestProfileImage(username: String, token: String) -> URLRequest {

        let unsplashGetProfileImageURLString = Constants.defaultBaseURLString + "users/" + username
        
        guard let url = URL(string: unsplashGetProfileImageURLString)
            else { fatalError("Failed to create URL") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("создан запрос на получение аватара \(request) с токеном \(token)")
        return request
    }
}
