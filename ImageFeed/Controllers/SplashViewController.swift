
import UIKit
import ProgressHUD
import SwiftKeychainWrapper
import SwiftUI

final class SplashViewController: UIViewController {

    //MARK: - Properties
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let loadingScreenImage = UIImageView()

    //MARK: - LifeCicle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        
        view.backgroundColor = UIColor(named: "YP Black")
        createLoadingScreenImage()
        
        NSLayoutConstraint.activate([
            loadingScreenImage.widthAnchor.constraint(equalToConstant: 75),
            loadingScreenImage.heightAnchor.constraint(equalToConstant: 78),
            loadingScreenImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            loadingScreenImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
            ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let token: String? = KeychainWrapper.standard.string(forKey: "Auth token")
        
        if token != nil {
            print("В памяти есть токен \(token!)")
            if !isProgressHUDVisible { UIBlockingProgressHUD.show() }
            print("Показываем заглушку с загрузкой 1")
            self.fetchProfile(token: token!)
        } else {
            print("Токена нет, переключаем на аутентификацию")
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("SplashView пропал")
    }

    //MARK: - Methods
    func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration")}
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token: token) { [weak self] result in
            
            guard let self = self else {
                UIBlockingProgressHUD.dismiss()
                print("Закрываем заглушку с загрузкой 1A")
                return
            }
            
            switch result {
            case .success(let profile):
                
                let isSuccessUsername = KeychainWrapper.standard.set(profile.username, forKey: "Username")
                let isSuccessLoginName = KeychainWrapper.standard.set(profile.loginName, forKey: "LoginName")
                let isSuccessName = KeychainWrapper.standard.set(profile.name, forKey: "Name")
                let isSuccessBio = KeychainWrapper.standard.set(profile.bio ?? "", forKey: "Bio")
                guard isSuccessUsername, isSuccessLoginName, isSuccessName, isSuccessBio else { return }
                
                self.profileImageService.fetchProfileImageURL(username: profile.username, token: token) { [weak self] result in
                    
                    switch result {
                    
                    case .success(let profileImage):
                        guard let self = self else {
                            UIBlockingProgressHUD.dismiss()
                            print("Self не существует. Закрываем заглушку с загрузкой 1B")
                            return
                        }
                        
                        let isSuccessImage = KeychainWrapper.standard.set(profileImage, forKey: "ImageURL")
                        guard isSuccessImage else {
                            UIBlockingProgressHUD.dismiss()
                            print("Не получилось установить аватар. Закрываем заглушку с загрузкой 1E")
                            return
                        }
                        
                        self.switchToTabBarController()
//                        UIBlockingProgressHUD.dismiss()
//                        print("Закрываем заглушку с загрузкой 1C")
                                                
                    case .failure:
                        
                        guard let self = self else { return }
                        self.showAlert()
//                        UIBlockingProgressHUD.dismiss()
//                        print("Закрываем заглушку с загрузкой 1D")
                        break
                    }
                    UIBlockingProgressHUD.dismiss()
                    print("Закрываем заглушку с загрузкой MAIN")
                }
                
            case .failure:
                self.showAlert()
                UIBlockingProgressHUD.dismiss()
                print("Закрываем заглушку с загрузкой 1F")
                break
            }
        }
    }
    
    func createLoadingScreenImage() {
        self.loadingScreenImage.translatesAutoresizingMaskIntoConstraints = false
        self.loadingScreenImage.image = UIImage(named: "VectorLoadingScreen")
        view.addSubview(self.loadingScreenImage)
    }
}



//MARK: - Extensions

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        
        let token: String? = KeychainWrapper.standard.string(forKey: "Auth token")
        guard let token = token else {
            print("Токен не найден")
            return
        }

        fetchProfile(token: token)
        
    }
}

extension SplashViewController {
    private func showAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: "Ок",
            style: .cancel,
            handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            })
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        }
    }


