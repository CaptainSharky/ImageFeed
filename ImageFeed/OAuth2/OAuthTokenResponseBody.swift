import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int

    static func decode(from data: Data) -> Result<OAuthTokenResponseBody, Error> {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
            return .success(response)
        } catch {
            print("Error: decode error")
            return .failure(error)
        }
    }
}
