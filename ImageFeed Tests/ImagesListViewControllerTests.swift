@testable import ImageFeed
import XCTest

final class ImagesListViewControllerTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController

        let presenter = ImagesListPresenterSpyMock()
        viewController.presenter = presenter
        presenter.view = viewController

        // When
        _ = viewController.view

        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testWillDisplayCallsPresenterWillDisplayRow() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController

        let presenter = ImagesListPresenterSpyMock()
        viewController.presenter = presenter
        presenter.view = viewController
        _ = viewController.view
        let tableView = viewController.value(forKey: "tableView") as! UITableView

        // When
        viewController.tableView(
            tableView,
            willDisplay: UITableViewCell(),
            forRowAt: IndexPath(row: 3, section: 0)
        )

        // Then
        XCTAssertEqual(presenter.willDisplayRowCalledIndex, 3)
    }

    func testDidTapLikeCallsPresenterDidTapLike() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController

        let presenter = ImagesListPresenterSpyMock()
        viewController.presenter = presenter
        presenter.view = viewController

        _ = viewController.view
        let tableView = viewController.value(forKey: "tableView") as! UITableView
        tableView.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        _ = viewController.tableView(tableView, cellForRowAt: indexPath)
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else { return }

        // When
        viewController.imageListCellDidTapLike(cell)

        // Then
        XCTAssertEqual(presenter.didTapLikeCalledIndex, 0)
        XCTAssertNotNil(presenter.didTapLikeCalledIndex)
    }

    func testNumberOfRowsInSectionReturnsPresenterCount() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController

        let presenter = ImagesListPresenterSpyMock()
        presenter.numberOfPhotos = 5
        viewController.presenter = presenter
        presenter.view = viewController
        _ = viewController.view
        let tableView = viewController.value(forKey: "tableView") as! UITableView
        // When
        let rows = viewController.tableView(tableView, numberOfRowsInSection: 0)

        // Then
        XCTAssertEqual(rows, 5)
    }

    func testHeightForRowUsesViewModelSize() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController

        let presenter = ImagesListPresenterSpyMock()
        presenter.numberOfPhotos = 1
        viewController.presenter = presenter
        presenter.view = viewController

        _ = viewController.view
        let tableView = viewController.value(forKey: "tableView") as! UITableView
        tableView.frame = CGRect(x: 0, y: 0, width: 320, height: 1000)
        // When
        let height = viewController.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 0))

        // Then
        XCTAssertGreaterThan(height, 0)
    }

    func testPrepareForSegueSetsFullImageURL() {
        // Given
        let presenter = ImagesListPresenterSpyMock()
        let viewController = ImagesListViewController()
        let destination = SingleImageViewController()
        let segue = UIStoryboardSegue(identifier: "ShowSingleImage", source: viewController, destination: destination) {
            destination.fullImageURL = presenter.getPhotoURL(at: 0)
        }

        viewController.presenter = presenter
        // When
        viewController.prepare(for: segue, sender: IndexPath(row: 0, section: 0))

        // Then
        XCTAssertEqual(destination.fullImageURL?.absoluteString, "https://example.com/full.jpg")
    }

    func testShowErrorDisplaysAlert() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController

        let presenter = ImagesListPresenterSpyMock()
        viewController.presenter = presenter
        presenter.view = viewController
        _ = viewController.view
        // When
        viewController.showError(message: "Ошибка загрузки")
        guard let presented = viewController.presentedViewController as? UIAlertController else { return }

        // Then
        XCTAssertEqual(presented.title, "Что-то пошло не так(")
        XCTAssertEqual(presented.message, "Ошибка загрузки")
        XCTAssertEqual(presented.actions.count, 1)
        XCTAssertEqual(presented.actions.first?.title, "Ок")
    }
}
