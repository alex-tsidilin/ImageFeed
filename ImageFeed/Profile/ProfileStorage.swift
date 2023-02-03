
import Foundation

final class ProfileStorage {

    private enum CodingKeys: String, CodingKey {
        case username
        case name
        case loginName
        case bio
        case image
    }

    private let userDefaults = UserDefaults.standard

    var username: String? {
        get { return userDefaults.string(forKey: CodingKeys.username.rawValue) }
        set { userDefaults.set(newValue, forKey: CodingKeys.username.rawValue) }
    }
    
    var name: String? {
        get { return userDefaults.string(forKey: CodingKeys.name.rawValue) }
        set { userDefaults.set(newValue, forKey: CodingKeys.name.rawValue) }
    }
    
    var loginName: String? {
        get { return userDefaults.string(forKey: CodingKeys.loginName.rawValue) }
        set { userDefaults.set(newValue, forKey: CodingKeys.loginName.rawValue) }
    }
    
    var bio: String? {
        get { return userDefaults.string(forKey: CodingKeys.bio.rawValue) }
        set { userDefaults.set(newValue, forKey: CodingKeys.bio.rawValue) }
    }
    
    var image: String? {
        get { return userDefaults.string(forKey: CodingKeys.image.rawValue) }
        set { userDefaults.set(newValue, forKey: CodingKeys.image.rawValue) }
    }
    
}

