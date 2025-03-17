import UIKit

final class ProfileViewController: UIViewController {
    private weak var avatarPhoto: UIImageView!
    private weak var userNameLabel: UILabel!
    private weak var nickNameLabel: UILabel!
    private weak var descriptionLabel: UILabel!
    private weak var exitButton: UIButton!
    
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
        activateConstraints()
    }
    
    private func configAvatarPhoto() {
        let photo = UIImage(named: "base_photo")
        let avatarPhoto = UIImageView(image: photo)
        avatarPhoto.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarPhoto)
        self.avatarPhoto = avatarPhoto
    }
    
    private func configUserNameLabel() {
        let userNameLabel = UILabel()
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.text = "Екатерина Новикова"
        userNameLabel.textColor = UIColor(named: "YP White")
        userNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        view.addSubview(userNameLabel)
        self.userNameLabel = userNameLabel
    }
    
    private func configNickNameLabel() {
        let nickNameLabel = UILabel()
        nickNameLabel.translatesAutoresizingMaskIntoConstraints = false
        nickNameLabel.text = "@ekaterina_nov"
        nickNameLabel.textColor = UIColor(named: "YP Gray")
        nickNameLabel.font = UIFont.systemFont(ofSize: 13)
        view.addSubview(nickNameLabel)
        self.nickNameLabel = nickNameLabel
    }
    
    private func configDescriptionLabel() {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = UIColor(named: "YP White")
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        view.addSubview(descriptionLabel)
        self.descriptionLabel = descriptionLabel
    }
    
    private func configExitButton() {
        let exitButton = UIButton(type: .custom)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.setImage(UIImage(named: "Exit"), for: .normal)
        view.addSubview(exitButton)
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
