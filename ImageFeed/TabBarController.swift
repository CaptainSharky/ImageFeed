import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController else { return }

        let imagesPresenter = ImagesListPresenter(view: imagesListViewController)
        imagesListViewController.presenter = imagesPresenter
        
        let profileViewController = ProfileViewController()
        let presenter = ProfilePresenter(view: profileViewController)
        profileViewController.presenter = presenter
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
