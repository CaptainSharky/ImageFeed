import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(
        rawValue: "ImagesListServiceDidChange"
    )
    private(set) var photos: [Photo] = []
    private var lastLoadedPage = 0
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private static let dateFormatter = ISO8601DateFormatter()

    private init() {}

    func fetchPhotosNextPage(token: String) {
        assert(Thread.isMainThread)
        task?.cancel()

        let nextPage = lastLoadedPage + 1
        guard let request = makeImagesListRequest(token, page: nextPage) else { return }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }

            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { item -> Photo in
                    let size = CGSize(width: item.width, height: item.height)
                    let createdDate = ImagesListService.dateFormatter.date(from: item.createdAt)
                    return Photo(
                        id: item.id,
                        size: size,
                        createdAt: createdDate,
                        welcomeDescription: item.description,
                        thumbImageURL: item.urls.thumb,
                        fullImageURL: item.urls.full,
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

    func changeLike(
        photoId: String,
        isLike: Bool,
        token: String,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        task?.cancel()

        guard let request = makeChangeLikeRequest(photoId: photoId, isLike: isLike, token) else {
            completion(.failure(ImagesListServiceError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<PhotoLikeResponse, Error>) in
            guard let self else { return }

            switch result {
            case .success:
                // let updated = response.photo
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            fullImageURL: photo.fullImageURL,
                            isLiked: !photo.isLiked
                        )
                        self.photos[index] = newPhoto
                    }
                    completion(.success(()))
                }
            case .failure(let error):
                print("[ImagesListService.changeLike]: Error - \(error.localizedDescription)")
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }

    func reset() {
        photos = []
        lastLoadedPage = 0
        task?.cancel()
        task = nil
    }

    private func makeChangeLikeRequest(photoId: String, isLike: Bool, _ token: String) -> URLRequest? {
        guard let url = URL(string: "/photos/\(photoId)/like", relativeTo: Constants.defaultBaseUrl) else {
            preconditionFailure("[ImagesListService.changeLike] Failed to build URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethods.post : HTTPMethods.delete
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func makeImagesListRequest(_ token: String, page: Int) -> URLRequest? {
        var components = URLComponents()
        components.host = Constants.defaultBaseUrl?.host
        components.scheme = Constants.defaultBaseUrl?.scheme
        components.path = "/photos"
        components.queryItems = [URLQueryItem(name: "page", value: "\(page)")]
        guard let url = components.url else {
            preconditionFailure("[ImagesListService.makeImagesListRequest] Failed to build URL")
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private enum ImagesListServiceError: Error {
        case invalidRequest
    }

    private struct PhotoLikeResponse: Decodable {
        let photo: PhotoResult
    }
}
