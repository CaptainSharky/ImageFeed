import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService: ProfileService
    private let imageService: ProfileImageService
    private let logoutService: ProfileLogoutService
    private var imageObserver: NSObjectProtocol?

    init(
        view: ProfileViewControllerProtocol,
        profileService: ProfileService = .shared,
        imageService: ProfileImageService = .shared,
        logoutService: ProfileLogoutService = .shared
    ) {
        self.view = view
        self.profileService = profileService
        self.imageService = imageService
        self.logoutService = logoutService
    }

    deinit {
        if let observer = imageObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func viewDidLoad() {
        guard let profile = profileService.profile else {
            view?.showError("Не удалось загрузить профиль")
            return
        }

        view?.displayProfile(
            name: profile.name,
            loginName: profile.loginName,
            bio: profile.bio
        )

        subscribeOnAvatarUpdates()

        let urlString = imageService.avatarURL
        view?.displayAvatar(urlString: urlString)
    }
    
    func didTapLogout() {
        logoutService.logout()
    }

    private func subscribeOnAvatarUpdates() {
        guard imageObserver == nil else { return }

        imageObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            let urlString = self.imageService.avatarURL
            self.view?.displayAvatar(urlString: urlString)
        }
    }
}
