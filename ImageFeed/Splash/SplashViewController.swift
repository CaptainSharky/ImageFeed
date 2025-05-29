import UIKit

final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let showAuthenticationScreenSegueIdentifier = "showAuthenticationScreen"
    private let tabBarViewControllerIdentifier = "TabBarViewController"
    private var logoImage: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = storage.token {
            fetchProfile(token)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
            guard let authViewController else { return }
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            self.present(authViewController, animated: true)
        }
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }

    private func setUI() {
        view.backgroundColor = UIColor(named: "YP Black")

        let logo = UIImage(named: "logo")
        let logoImage = UIImageView(image: logo)
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImage)
        NSLayoutConstraint.activate([
            logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        self.logoImage = logoImage
    }

    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось получить профиль",
            preferredStyle: .alert
        )
        let okayButton = UIAlertAction(title: "Ок", style: .default)
        alert.addAction(okayButton)
        self.present(alert, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)

        guard let token = storage.token else { return }

        fetchProfile(token)
    }

    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case .success(let profile):
                profileImageService.fetchProfileImageURL(username: profile.username, token: token) { result in
                    switch result {
                    case .success(let avatarURL):
                        print("Avatar URL: \(avatarURL)")
                    case .failure:
                        self.showErrorAlert()
                    }
                }
                self.switchToTabBarController()
            case .failure:
                showErrorAlert()
            }
        }
    }
}
