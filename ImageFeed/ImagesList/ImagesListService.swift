import Foundation

final class ImagesListService {
    static let didChangeNotification = Notification.Name(
        rawValue: "ImagesListServiceDidChange"
    )
    private(set) var photos: [Photo] = []
    private var lastLoadedPage = 0
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?


    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        task?.cancel()

        let nextPage = lastLoadedPage + 1

        guard let request = makeImagesListRequest() else { return }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }

            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { item -> Photo in
                    let size = CGSize(width: item.width, height: item.height)
                    let createdDate = ISO8601DateFormatter().date(from: item.createdAt)
                    return Photo(
                        id: item.id,
                        size: size,
                        createdAt: createdDate,
                        welcomeDescription: item.description,
                        thumbImageURL: item.urls.thumb,
                        largeImageURL: item.urls.regular,
                        isLiked: item.likedByUser
                    )
                }
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
            case .failure(let error):
                print("[ImagesListService] Error fetching photos: \(error.localizedDescription)")
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }

    private func makeImagesListRequest() -> URLRequest? {
        guard let url = URL(string: "/photos", relativeTo: Constants.defaultBaseUrl) else {
            preconditionFailure("Error: invalid base URL")
        }
        return URLRequest(url: url)
    }
}
