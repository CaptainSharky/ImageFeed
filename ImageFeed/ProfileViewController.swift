import UIKit

final class ProfileViewController: UIViewController {
    @IBOutlet weak var avatarPhoto: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func exitButton(_ sender: Any) { }
}
