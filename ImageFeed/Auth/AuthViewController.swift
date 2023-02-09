
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
    private let authScreenImage = UIImageView()
    //private let authButton = UIButton()
    
    weak var delegate: AuthViewControllerDelegate?
    
    @IBOutlet weak var authButton: UIButton!
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Загрузили экран AuthViewController")
        authButton.layer.masksToBounds = true
        authButton.layer.cornerRadius = 16
        
//        view.backgroundColor = UIColor(named: "YP Black")
//        createAuthScreenImage()
//        createAuthButton()
//
//        NSLayoutConstraint.activate([
//            authScreenImage.widthAnchor.constraint(equalToConstant: 60),
//            authScreenImage.heightAnchor.constraint(equalToConstant: 60),
//            authScreenImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
//            authScreenImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
//            authButton.heightAnchor.constraint(equalToConstant: 48),
//            authButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
//            authButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
//            authButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
//            ])
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
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
    
//    func createAuthScreenImage() {
//        self.authScreenImage.translatesAutoresizingMaskIntoConstraints = false
//        self.authScreenImage.image = UIImage(named: "AuthIcon")
//        view.addSubview(self.authScreenImage)
//    }
//
//    func createAuthButton() {
//        self.authButton.translatesAutoresizingMaskIntoConstraints = false
//        self.authButton.layer.masksToBounds = true
//        self.authButton.layer.cornerRadius = 16
//        self.authButton.backgroundColor = .white
//        self.authButton.setTitle("Войти", for: .normal)
//
//        let font = UIFont(name: "YS Display Bold", size: 17)
//        self.authButton.titleLabel?.font = font
//
//        let color = UIColor(named: "YP Black")
//        self.authButton.setTitleColor(color, for: .normal)
//
//        self.authButton.addTarget(self, action: #selector(handleAuthButtonTap), for: .touchUpInside)
//        view.addSubview(self.authButton)
//    }
//
//    @objc func handleAuthButtonTap() {
//        let webViewController = WebViewViewController()
//        present(webViewController, animated: true, completion: nil)
//    }
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


