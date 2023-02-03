
import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {

    //MARK: - Properties
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    let tokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared

    //MARK: - LifeCicle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if tokenStorage.token != nil {
            print("В памяти есть токен \(tokenStorage.token!)")
            UIBlockingProgressHUD.show()
            print("Показываем заглушку с загрузкой 1")
            self.fetchProfile(token: tokenStorage.token!)
            //switchToTabBarController()
        } else {
            print("Токена нет, переключаем на аутентификацию")
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
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
                print("Закрываем заглушку с загрузкой 1c")
                return
            }
            
            switch result {
            case .success:
                self.switchToTabBarController()
                UIBlockingProgressHUD.dismiss()
                print("Закрываем заглушку с загрузкой 1a")
            case .failure:
                UIBlockingProgressHUD.dismiss()
                print("Закрываем заглушку с загрузкой 1b")
                // TODO [Sprint 11] Показать ошибку
                break
            }
        }
    }
}

//MARK: - Extensions
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")}
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        switchToTabBarController()
    }

}
