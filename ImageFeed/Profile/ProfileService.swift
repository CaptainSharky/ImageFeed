import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private(set) var profile: Profile?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?

    private init() {}

    private func makeProfileInfoRequest(authToken: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            preconditionFailure("Error: invalid base URL")
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }

    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        task?.cancel()

        guard let request = makeProfileInfoRequest(authToken: token) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }

        let task = urlSession.data(for: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Received JSON: \(jsonString)")
                    }
                    switch ProfileResult.decode(from: data) {
                    case .success(let responseBody):
                        self?.profile = responseBody
                        print(responseBody.loginName)
                        completion(.success(responseBody))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("Error: (Profile Service) urlSession.data error - \(error)")
                    completion(.failure(error))
                }

                self?.task = nil
            }
        }
        self.task = task
        task.resume()
    }

    private enum ProfileServiceError: Error {
        case invalidRequest
    }
}
