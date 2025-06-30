@testable import ImageFeed
import Foundation

final class ImagesListPresenterSpyMock: ImagesListPresenterProtocol {
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
