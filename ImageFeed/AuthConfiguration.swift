import Foundation

enum Constants {
    static let accessKey = "rj74MafohtH60O4p7pVZqi5Euw2u-xo4hfHZA19QQVc"
    static let secretKey = "uKJXhSN7SfmdytEfcUC-CjYWlfmH29S3_cptm0K1bIo"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let defaultBaseUrl: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            preconditionFailure("[Constants]: Error while creating defaultBaseUrl")
        }
        return url
    }()
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    static var standard: AuthConfiguration {
        AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            defaultBaseURL: Constants.defaultBaseUrl,
            authURLString: Constants.unsplashAuthorizeURLString
        )
    }
}

enum HTTPMethods {
    static let get = "GET"
    static let post = "POST"
    static let put = "PUT"
    static let delete = "DELETE"
}
