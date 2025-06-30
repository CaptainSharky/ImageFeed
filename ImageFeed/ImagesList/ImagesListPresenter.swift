import Foundation

struct ImagesListCellViewModel {
    let thumbURL: URL?
    let date: String?
    let isLiked: Bool
    let imageSize: CGSize
}

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var numberOfPhotos: Int { get }
    func viewDidLoad()
    func willDisplayRow(at index: Int)
    func cellViewModel(for index: Int) -> ImagesListCellViewModel
    func didTapLike(at index: Int)
    func getPhotoURL(at index: Int) -> URL?
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private let service: ImagesListService
    private let tokenStorage: OAuth2TokenStorage
    private let dateFormatter: DateFormatter
    private var serviceObserver: NSObjectProtocol?
    private var photos: [Photo] = []

    var numberOfPhotos: Int { photos.count }

    init(
        view: ImagesListViewControllerProtocol,
        service: ImagesListService = .shared,
        tokenStorage: OAuth2TokenStorage = .shared
    ) {
        self.view = view
        self.service = service
        self.tokenStorage = tokenStorage
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
    }

    deinit {
        if let serviceObserver {
            NotificationCenter.default.removeObserver(serviceObserver)
        }
    }

    func viewDidLoad() {
        serviceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: service,
            queue: .main
        ) { [weak self] _ in
            self?.handleServiceChange()
        }

        guard let token = tokenStorage.token else {
            view?.showError(message: "Не удалось загрузить фото")
            return
        }
        service.fetchPhotosNextPage(token: token)
    }
    
    func willDisplayRow(at index: Int) {
        if index == photos.count - 1, let token = tokenStorage.token {
            service.fetchPhotosNextPage(token: token)
        }
    }
    
    func cellViewModel(for index: Int) -> ImagesListCellViewModel {
        let photo = photos[index]
        let url = URL(string: photo.thumbImageURL)
        let date = photo.createdAt.map { dateFormatter.string(from: $0) }
        return ImagesListCellViewModel(
            thumbURL: url,
            date: date,
            isLiked: photo.isLiked,
            imageSize: photo.size
        )
    }
    
    func didTapLike(at index: Int) {
        guard let token = tokenStorage.token else { return }
        view?.setLoading(true)
        let photo = photos[index]

        service.changeLike(
            photoId: photo.id,
            isLike: !photo.isLiked,
            token: token
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.view?.setLoading(false)
                switch result {
                case .success:
                    let updated = self.service.photos[index]
                    self.photos[index] = updated
                    self.view?.updateLike(at: index, isLiked: updated.isLiked)
                case .failure:
                    self.view?.showError(message: "Не удалось изменить лайк")
                }
            }
        }
    }
    
    func getPhotoURL(at index: Int) -> URL? {
        let photo = photos[index]
        guard let url = URL(string: photo.fullImageURL) else { return nil }
        return url
    }

    private func handleServiceChange() {
        let oldCount = photos.count
        let newCount = service.photos.count
        photos = service.photos
        if newCount < oldCount {
            view?.reloadTableData()
        } else if oldCount < newCount {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            view?.insertRows(at: indexPaths)
        }
    }
}
