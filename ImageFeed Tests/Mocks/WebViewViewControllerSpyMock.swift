@testable import ImageFeed
import Foundation

final class WebViewViewControllerSpyMock: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var presenterCalledLoadRequest: Bool = false

    func load(request: URLRequest) {
        presenterCalledLoadRequest = true
    }

    func setProgressValue(_ newValue: Float) {

    }

    func setProgressHidden(_ isHidden: Bool) {

    }
}
