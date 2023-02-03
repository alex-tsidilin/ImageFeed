
import Foundation

struct OAuthTokenResponseBody: Codable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope = "scope"
        case createdAt = "created_at"
    }
}

final class OAuth2Service {
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private var lastRequest: URLRequest?
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        let request = makeRequest(code: code)
        
        if lastRequest != nil { return }
        lastRequest = request
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                
                guard let data = data else { return }

                do {
                    let jsonData = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(jsonData.accessToken))
                } catch let error {
                    completion(.failure(error))
                }
                
                self.task = nil
                if error != nil {
                    self.lastCode = nil
                    self.lastRequest = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeRequest(code: String) -> URLRequest {  // 19 Функция для создания URLRequest с заданным code.
        let unsplashAuthorizePostURLString = "https://unsplash.com/oauth/token"
        var urlComponents = URLComponents(string: unsplashAuthorizePostURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else { fatalError("Failed to create URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}

