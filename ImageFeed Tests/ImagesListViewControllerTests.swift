@testable import ImageFeed
import XCTest

final class ImagesListViewControllerTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController

        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        // when
        _ = viewController.view

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testWillDisplayCallsPresenterWillDisplayRow() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController

        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        _ = viewController.view
        let tableView = viewController.value(forKey: "tableView") as! UITableView

        // when
        viewController.tableView(
            tableView,
            willDisplay: UITableViewCell(),
            forRowAt: IndexPath(row: 3, section: 0)
        )

        // then
        XCTAssertEqual(presenter.willDisplayRowCalledIndex, 3)
    }

    func testDidTapLikeCallsPresenterDidTapLike() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController

        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        _ = viewController.view
        let tableView = viewController.value(forKey: "tableView") as! UITableView
        tableView.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        _ = viewController.tableView(tableView, cellForRowAt: indexPath)
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else { return }

        // when
        viewController.imageListCellDidTapLike(cell)

        // then
        XCTAssertEqual(presenter.didTapLikeCalledIndex, 0)
        XCTAssertNotNil(presenter.didTapLikeCalledIndex)
    }

    func testNumberOfRowsInSectionReturnsPresenterCount() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController

        let presenter = ImagesListPresenterSpy()
        presenter.numberOfPhotos = 5
        viewController.presenter = presenter
        presenter.view = viewController
        _ = viewController.view
        let tableView = viewController.value(forKey: "tableView") as! UITableView
        // when
        let rows = viewController.tableView(tableView, numberOfRowsInSection: 0)

        // then
        XCTAssertEqual(rows, 5)
    }

    func testHeightForRowUsesViewModelSize() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController

        let presenter = ImagesListPresenterSpy()
        presenter.numberOfPhotos = 1
        viewController.presenter = presenter
        presenter.view = viewController

        _ = viewController.view
        let tableView = viewController.value(forKey: "tableView") as! UITableView
        tableView.frame = CGRect(x: 0, y: 0, width: 320, height: 1000)
        // when
        let height = viewController.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 0))

        // then
        XCTAssertGreaterThan(height, 0)
    }

    func testPrepareForSegueSetsFullImageURL() {
        // given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewController()
        let destination = SingleImageViewController()
        let segue = UIStoryboardSegue(identifier: "ShowSingleImage", source: viewController, destination: destination) {
            destination.fullImageURL = presenter.getPhotoURL(at: 0)
        }

        viewController.presenter = presenter
        // when
        viewController.prepare(for: segue, sender: IndexPath(row: 0, section: 0))

        // then
        XCTAssertEqual(destination.fullImageURL?.absoluteString, "https://example.com/full.jpg")
    }

    func testShowErrorDisplaysAlert() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController

        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        _ = viewController.view
        // when
        viewController.showError(message: "Ошибка загрузки")
        guard let presented = viewController.presentedViewController as? UIAlertController else { return }

        // then
        XCTAssertEqual(presented.title, "Что-то пошло не так(")
        XCTAssertEqual(presented.message, "Ошибка загрузки")
        XCTAssertEqual(presented.actions.count, 1)
        XCTAssertEqual(presented.actions.first?.title, "Ок")
    }
}

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImageFeed.ImagesListViewControllerProtocol?
    var numberOfPhotos: Int = 10
    var viewDidLoadCalled = false
    var willDisplayRowCalledIndex: Int?
    var didTapLikeCalledIndex: Int?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func willDisplayRow(at index: Int) {
        willDisplayRowCalledIndex = index
    }

    func cellViewModel(for index: Int) -> ImageFeed.ImagesListCellViewModel {
        return ImagesListCellViewModel(
            thumbURL: nil,
            date: "today",
            isLiked: true,
            imageSize: CGSize(width: 1, height: 1)
        )
    }

    func didTapLike(at index: Int) {
        didTapLikeCalledIndex = index
    }

    func getPhotoURL(at index: Int) -> URL? {
        return URL(string: "https://example.com/full.jpg")
    }
}
