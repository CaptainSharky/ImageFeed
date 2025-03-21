import UIKit

final class AuthViewController: UIViewController {
    private let showWebViewIdentifier = "ShowWebView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button_black")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button_black")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
}
