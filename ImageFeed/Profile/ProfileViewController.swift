
import UIKit
import ProgressHUD
import Kingfisher
import SwiftKeychainWrapper

final class ProfileViewController: UIViewController {
    
    let profileImage = UIImageView()
    let logoutButton = UIButton()
    let profileName = UILabel()
    let profileID = UILabel()
    let profileDescription = UILabel()
    let profileService = ProfileService()
    let profileImageService = ProfileImageService()
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    private let profileStorage = ProfileStorage()
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {

        createProfileImage(profileImage: profileImage)
        createLogoutButton(logoutButton: logoutButton)
        createProfileName(profileName: profileName)
        createProfileID(profileID: profileID)
        createProfileDescription(profileDescription: profileDescription)
                        
        NSLayoutConstraint.activate([
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileName.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            profileName.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            logoutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.heightAnchor.constraint(equalToConstant: 24),
            profileID.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            profileID.topAnchor.constraint(equalTo: profileName.bottomAnchor, constant: 8),
            profileDescription.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            profileDescription.topAnchor.constraint(equalTo: profileID.bottomAnchor, constant: 8),
        ])
        
        updateUserDataFromStorage()
        
        profileImageServiceObserver = NotificationCenter.default
                    .addObserver(
                        forName: ProfileImageService.DidChangeNotification,
                        object: nil,
                        queue: .main
                    ) { [weak self] _ in
                        guard let self = self else { return }
                        self.updateAvatar()
                    }
                updateAvatar()
        
    }
    
    func createProfileImage(profileImage: UIImageView) {
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.image = UIImage(named: "Photo")
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        view.addSubview(profileImage)
    }
    
    func createLogoutButton(logoutButton: UIButton) {
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.tintColor = UIColor(named: "YP Red")
        logoutButton.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        view.addSubview(logoutButton)
    }
    
    func createProfileName(profileName: UILabel) {
        profileName.translatesAutoresizingMaskIntoConstraints = false
        profileName.text = "Екатерина Новикова"
        profileName.font = UIFont(name: "YS Display Bold", size: 23)
        profileName.textColor = .white
        view.addSubview(profileName)
    }
    
    func createProfileID(profileID: UILabel) {
        profileID.translatesAutoresizingMaskIntoConstraints = false
        profileID.text = "@ekaterina_nov"
        profileID.font = UIFont(name: "YS Display Medium", size: 13)
        profileID.textColor = UIColor(named: "YP Gray")
        view.addSubview(profileID)
    }
    
    func createProfileDescription(profileDescription: UILabel) {
        profileDescription.translatesAutoresizingMaskIntoConstraints = false
        profileDescription.text = "Hello, world!"
        profileDescription.font = UIFont(name: "YS Display Medium", size: 13)
        profileDescription.textColor = .white
        view.addSubview(profileDescription)
    }
    
    func updateUserDataFromStorage() {
        self.profileName.text = KeychainWrapper.standard.string(forKey: "Name") ?? "Имя Фамилия"
        self.profileID.text = "@" + (KeychainWrapper.standard.string(forKey: "Username") ?? "username")
        self.profileDescription.text = KeychainWrapper.standard.string(forKey: "Bio") ?? "Биография пользователя"
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = KeychainWrapper.standard.string(forKey: "ImageURL"),
            let url = URL(string: profileImageURL)
        else { return }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        
        let optionsInfo: KingfisherOptionsInfo = [
            .cacheSerializer(FormatIndicatedCacheSerializer.png),
            .processor(processor)]
        
        profileImage.kf.setImage(with: url,
                                 placeholder: nil,
                                 options: optionsInfo)
    }
}
