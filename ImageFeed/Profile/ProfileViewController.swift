import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func displayProfile(name: String, loginName: String, bio: String)
    func displayAvatar(urlString: String?)
    func showError(_ message: String)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    private var avatarPhoto: UIImageView?
    private var userNameLabel: UILabel?
    private var nickNameLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var exitButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUIElements()
        presenter?.viewDidLoad()
    }

    func displayProfile(name: String, loginName: String, bio: String) {
        userNameLabel?.text = name
        nickNameLabel?.text = loginName
        descriptionLabel?.text = bio
    }

    func displayAvatar(urlString: String?) {
        if let urlString, let url = URL(string: urlString) {
            avatarPhoto?.kf.setImage(
                with: url,
                placeholder: UIImage(resource: .avatarDefault),
                options: [.processor(RoundCornerImageProcessor(cornerRadius: 16))]
            )
        } else {
            avatarPhoto?.image = UIImage(resource: .avatarDefault)
        }
    }

    func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: message,
            preferredStyle: .alert
        )
        let okayButton = UIAlertAction(title: "Ок", style: .default)
        alert.addAction(okayButton)
        present(alert, animated: true)
    }

    private func setUIElements() {
        configAvatarPhoto()
        configUserNameLabel()
        configNickNameLabel()
        configDescriptionLabel()
        configExitButton()

        [avatarPhoto, userNameLabel, nickNameLabel, descriptionLabel, exitButton].forEach {
            guard let element = $0 else { return }
            element.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(element)
        }

        activateConstraints()
        view.backgroundColor = UIColor(resource: .ypBlack)
    }

    @objc private func didTapExitButton() {
        presenter?.didTapLogout()
    }

    private func configAvatarPhoto() {
        let photo = UIImage(resource: .basePhoto)
        let avatarPhoto = UIImageView(image: photo)
        self.avatarPhoto = avatarPhoto
    }

    private func configUserNameLabel() {
        let userNameLabel = UILabel()
        userNameLabel.text = "Екатерина Новикова"
        userNameLabel.textColor = UIColor(resource: .ypWhite)
        userNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        self.userNameLabel = userNameLabel
    }

    private func configNickNameLabel() {
        let nickNameLabel = UILabel()
        nickNameLabel.text = "@ekaterina_nov"
        nickNameLabel.textColor = UIColor(resource: .ypGray)
        nickNameLabel.font = UIFont.systemFont(ofSize: 13)
        self.nickNameLabel = nickNameLabel
    }

    private func configDescriptionLabel() {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = UIColor(resource: .ypWhite)
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        self.descriptionLabel = descriptionLabel
    }

    private func configExitButton() {
        let exitButton = UIButton(type: .custom)
        exitButton.accessibilityIdentifier = "logout button"
        exitButton.setImage(UIImage(resource: .exit), for: .normal)
        exitButton.addTarget(self, action: #selector(didTapExitButton), for: .touchUpInside)
        self.exitButton = exitButton
    }

    private func activateConstraints() {
        guard
            let avatarPhoto,
            let userNameLabel,
            let nickNameLabel,
            let descriptionLabel,
            let exitButton
        else { return }
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
