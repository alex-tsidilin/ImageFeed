
import UIKit
import ProgressHUD
import SwiftKeychainWrapper

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oAuth2Service = OAuth2Service()
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService()
    
    weak var delegate: AuthViewControllerDelegate?
    
    @IBOutlet weak var authButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Загрузили экран AuthViewController")
        authButton.layer.masksToBounds = true
        authButton.layer.cornerRadius = 16
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(showWebViewSegueIdentifier)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        print("Показываем заглушку с загрузкой 2")
        oAuth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
            
                switch result {
                case .success(let token):
                    print("Мы получили токен \(token)")
                    let isSuccess = KeychainWrapper.standard.set(token, forKey: "Auth token")
                    guard isSuccess else { return }
                    self.delegate?.authViewController(self, didAuthenticateWithCode: code)
                    //UIBlockingProgressHUD.dismiss()
                    print("Закрываем заглушку с загрузкой 2")
                case .failure(let error):
                    print(error)
                    UIBlockingProgressHUD.dismiss()
                    print("Закрываем заглушку с загрузкой 2")
                }
            }
        }
    }
}


