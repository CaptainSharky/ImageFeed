import UIKit

final class ProfileViewController: UIViewController {
    private var avatarPhoto: UIImageView!
    private var userNameLabel: UILabel!
    private var nickNameLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var exitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUIElements()
    }
    
    private func setUIElements() {
        configAvatarPhoto()
        configUserNameLabel()
        configNickNameLabel()
        configDescriptionLabel()
        configExitButton()
        
        [avatarPhoto, userNameLabel, nickNameLabel, descriptionLabel, exitButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        activateConstraints()
    }
    
    private func configAvatarPhoto() {
        let photo = UIImage(named: "base_photo")
        let avatarPhoto = UIImageView(image: photo)
        self.avatarPhoto = avatarPhoto
    }
    
    private func configUserNameLabel() {
        let userNameLabel = UILabel()
        userNameLabel.text = "Екатерина Новикова"
        userNameLabel.textColor = UIColor(named: "YP White")
        userNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        self.userNameLabel = userNameLabel
    }
    
    private func configNickNameLabel() {
        let nickNameLabel = UILabel()
        nickNameLabel.text = "@ekaterina_nov"
        nickNameLabel.textColor = UIColor(named: "YP Gray")
        nickNameLabel.font = UIFont.systemFont(ofSize: 13)
        self.nickNameLabel = nickNameLabel
    }
    
    private func configDescriptionLabel() {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = UIColor(named: "YP White")
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        self.descriptionLabel = descriptionLabel
    }
    
    private func configExitButton() {
        let exitButton = UIButton(type: .custom)
        exitButton.setImage(UIImage(named: "Exit"), for: .normal)
        self.exitButton = exitButton
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            avatarPhoto.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarPhoto.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarPhoto.widthAnchor.constraint(equalToConstant: 70),
            avatarPhoto.heightAnchor.constraint(equalToConstant: 70),
            userNameLabel.leadingAnchor.constraint(equalTo: avatarPhoto.leadingAnchor),
            userNameLabel.topAnchor.constraint(equalTo: avatarPhoto.bottomAnchor, constant: 8),
            nickNameLabel.leadingAnchor.constraint(equalTo: avatarPhoto.leadingAnchor),
            nickNameLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarPhoto.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 8),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.centerYAnchor.constraint(equalTo: avatarPhoto.centerYAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
