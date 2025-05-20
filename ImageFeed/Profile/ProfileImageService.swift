import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private(set) var avatarURL: String?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?

    private init() {}

    private func makeProfileImageRequest(authToken: String, username: String) -> URLRequest? {
        guard let url = URL(string: "/users/\(username)", relativeTo: Constants.defaultBaseUrl) else {
            preconditionFailure("Error: invalid base URL")
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }

    func fetchProfileImageURL(
        username: String,
        token: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        task?.cancel()

        guard let request = makeProfileImageRequest(authToken: token, username: username) else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let response):
                guard let profileImageURL = response.profileImage?["small"] else {
                    print("[ProfileImageService.fetchProfileImageURL]: Error - missing profileImage URL")
                    completion(.failure(ProfileImageServiceError.invalidRequest))
                    return
                }
                self?.avatarURL = profileImageURL
                print("[ProfileImageService.fetchProfileImageURL]: Success - URL: \(profileImageURL)")
                completion(.success(profileImageURL))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImageURL])
            case .failure(let error):
                print("[ProfileImageService.fetchProfileImageURL]: Error - \(error.localizedDescription)")
                completion(.failure(error))
            }
            self?.task = nil
        }
        self.task = task
        task.resume()
    }

    private enum ProfileImageServiceError: Error {
        case invalidRequest
    }
}

struct UserResult: Codable {
    let profileImage: [String: String]?
}
