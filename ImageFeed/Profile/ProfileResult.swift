import Foundation

struct ProfileResult: Codable {
    let username: String?
    let firstName: String?
    let lastName: String?
    let bio: String?

    static func decode(from data: Data) -> Result<Profile, Error> {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response = try decoder.decode(ProfileResult.self, from: data)

            let username = response.username ?? ""
            let name = "\(response.firstName ?? "") \(response.lastName ?? "")"
            let loginName = "@\(username)"
            let bio = response.bio ?? ""

            return .success(Profile(username: username, name: name, loginName: loginName, bio: bio))
        } catch {
            print("Error: profile decode error - \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
