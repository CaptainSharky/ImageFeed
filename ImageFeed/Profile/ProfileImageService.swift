import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private(set) var avatarURL: String?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?

    private init() {}

    private func makeProfileImageRequest(authToken: String, username: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
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

        let task = urlSession.data(for: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    switch UserResult.decode(from: data) {
                    case .success(let responseBody):
                        guard let profileImageURL = responseBody.profileImage?["small"] else { break }
                        self?.avatarURL = profileImageURL
                        completion(.success(profileImageURL))
                        NotificationCenter.default
                            .post(
                                name: ProfileImageService.didChangeNotification,
                                object: self,
                                userInfo: ["URL": profileImageURL])
                    case .failure(let error):
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("Error: (ProfileImageService) urlSession.data error - \(error)")
                    completion(.failure(error))
                }
                self?.task = nil
            }
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

    static func decode(from data: Data) -> Result<UserResult, Error> {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response = try decoder.decode(UserResult.self, from: data)

            return .success(response)
        } catch {
            print("Error: profile image decode error - \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
