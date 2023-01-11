
import Foundation

final class OAuth2TokenStorage {

    private enum CodingKeys: String, CodingKey {
        case token
    }

    private let userDefaults = UserDefaults.standard

    var token: String? {
        get { return userDefaults.string(forKey: CodingKeys.token.rawValue) }
        set { userDefaults.set(newValue, forKey: CodingKeys.token.rawValue) }
    }
}
