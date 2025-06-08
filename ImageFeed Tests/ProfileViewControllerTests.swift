@testable import ImageFeed
import XCTest

final class ProfileViewControllerTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        // when
        _ = viewController.view

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testDidTapExitButtonCallsPresenterDidTapLogout() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        let exitButton = viewController.view.subviews
            .compactMap { $0 as? UIButton }
            .first { button in
                true
            }

        // when
        exitButton?.sendActions(for: .touchUpInside)

        // then
        XCTAssertNotNil(exitButton)
        XCTAssertTrue(presenter.didTapLogoutCalled)
    }

    func testDisplayProfileShowsUserData() {
        // given
        let viewController = ProfileViewController()

        let testName = "Test User"
        let testLogin = "@test_user"
        let testBio = "test bio."

        let labels = viewController.view.subviews.compactMap { $0 as? UILabel }
        let nameLabel = labels[0]
        let loginLabel = labels[1]
        let bioLabel = labels[2]

        // when
        viewController.displayProfile(name: testName, loginName: testLogin, bio: testBio)

        // then
        XCTAssertEqual(labels.count, 3)
        XCTAssertEqual(nameLabel.text, testName)
        XCTAssertEqual(loginLabel.text, testLogin)
        XCTAssertEqual(bioLabel.text, testBio)
    }

    func testShowErrorPresentsAlert() {
        // given
        let message = "Ошибка"
        let viewController = ProfileViewController()

        // when
        viewController.showError(message)

        // then
        guard let alert = viewController.presentedViewController as? UIAlertController else { return }
        XCTAssertEqual(alert.title, "Что-то пошло не так(")
        XCTAssertEqual(alert.message, message)
        XCTAssertEqual(alert.actions.first?.title, "Ок")
    }

    func testSubscribeOnAvatarUpdatedCreatedObserver() {
        // given
        let presenter = ProfilePresenterSpy()

        // when
        presenter.subscribeOnAvatarUpdates()

        // then
        XCTAssertNotNil(presenter.imageObserver)
    }
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var didTapLogoutCalled = false
    var imageObserver: NSObjectProtocol?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didTapLogout() {
        didTapLogoutCalled = true
    }

    func subscribeOnAvatarUpdates() {
        guard imageObserver == nil else { return }

        imageObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { _ in

        }
    }
}
