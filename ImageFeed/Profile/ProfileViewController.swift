import UIKit

final class ProfileViewController: UIViewController {
    @IBOutlet private weak var avatarPhoto: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var nickNameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var exitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func exitButtonTapped(_ sender: Any) { }
}
