
import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private (set) var avatarURL: String?
    let profileStorage = ProfileStorage()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    private var lastUsername: String?
    private var profileImage: ProfileImage?
    
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

                guard let data = data else {
                    print("Нет данных")
                    return
                }

                print("получаем данные \(data)")
                print(String(data: data, encoding: .utf8))

                do {
                    let json = try JSONDecoder().decode(ProfileImage.self, from: data)
                    print("получаем такой json \(json)")

                    guard let profile = json.profileImage.small else { return }
                    self.avatarURL = profile
                    self.profileStorage.image = profile
                    print("Получили ссылку на автарку \(profile)")

                    completion(.success(profile))
                
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                    
                
                } catch let error {
                    print("Поймали error")
                    print("Failed to parse: \(error.localizedDescription)")
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
    
    func requestProfileImage(username: String, token: String) -> URLRequest {

        let unsplashGetProfileImageURLString = Constants.defaultBaseURLString + "users/:" + username
        
        guard let url = URL(string: unsplashGetProfileImageURLString)
            else { fatalError("Failed to create URL") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("создан запрос на получение аватара \(request) с токеном \(token)")
        return request
    }
}
