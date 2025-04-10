import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}

    func makeOAuthTokenRequest(code: String) -> URLRequest {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            preconditionFailure("Invalid base URL")
        }

        var components = URLComponents()
        components.path = "/oauth/token"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        guard let url = components.url(relativeTo: baseURL) else {
            preconditionFailure("Error: failed to create URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request = makeOAuthTokenRequest(code: code)
        let session = URLSession.shared

        let task = session.data(for: request) { result in
            switch result {
            case .success(let data):
                switch OAuthTokenResponseBody.decode(from: data) {
                case .success(let responseBody):
                    completion(.success(responseBody.accessToken))
                case .failure(let error):
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
