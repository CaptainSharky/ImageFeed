import Foundation

enum Constants {
    static let accessKey = "rj74MafohtH60O4p7pVZqi5Euw2u-xo4hfHZA19QQVc"
    static let secretKey = "uKJXhSN7SfmdytEfcUC-CjYWlfmH29S3_cptm0K1bIo"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseUrl = URL(string: "https://api.unsplash.com")
}

enum HTTPMethods {
    static let get = "GET"
    static let post = "POST"
    static let put = "PUT"
    static let delete = "DELETE"
}
