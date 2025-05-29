import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private(set) var profile: Profile?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?

    private init() {}

    private func makeProfileInfoRequest(authToken: String) -> URLRequest? {
        guard let url = URL(string: "/me", relativeTo: Constants.defaultBaseUrl) else {
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

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let response):
                let username = response.username ?? ""
                let name = "\(response.firstName ?? "") \(response.lastName ?? "")"
                let loginName = "@\(username)"
                let bio = response.bio ?? ""
                let profile = Profile(username: username, name: name, loginName: loginName, bio: bio)
                self?.profile = profile
                print("[ProfileService.fetchProfile]: Success - \(loginName)")
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService.fetchProfile]: Error - \(error.localizedDescription)")
                completion(.failure(error))
            }
            self?.task = nil
        }
        self.task = task
        task.resume()
    }

    func reset() {
        profile = nil
    }

    private enum ProfileServiceError: Error {
        case invalidRequest
    }
}
