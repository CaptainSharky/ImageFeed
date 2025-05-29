import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared

    private init() { }

    func logout() {
        OAuth2TokenStorage().token = nil

        profileService.reset()
        profileImageService.reset()
        imagesListService.reset()
        cleanCookies()

        switchToSplashViewController()
    }

    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
