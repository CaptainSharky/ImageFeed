import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView! // Таблица-лента
    private let photosName: [String] = Array(0..<20).map { "\($0)" } // Названия mock-фотографий
    private let showSingleImageSegueIdentifier = "ShowSingleImage" // Идентификатор перехода
    private let imagesListService = ImagesListService.shared
    private let token = OAuth2TokenStorage().token
    var photos: [Photo] = []

    // Отформатировать дату
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(imagesListDidChange),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        guard let token else { return }
        imagesListService.fetchPhotosNextPage(token: token)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                return
            }
            
            let photo = photos[indexPath.row]
            viewController.fullImageURL = URL(string: photo.fullImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }

    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось изменить лайк",
            preferredStyle: .alert
        )
        let okayButton = UIAlertAction(title: "Ок", style: .default)
        alert.addAction(okayButton)
        self.present(alert, animated: true)
    }

    @objc private func imagesListDidChange(_ notification: Notification) {
        updateTableViewAnimated()
    }
}
// MARK: - Extensions
extension ImagesListViewController: UITableViewDelegate {
    // Обработать нажатие на ячейку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    // Настроить динамическую высоту ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width

        guard imageWidth > 0 else { return 200 }
        let scale = imageViewWidth / imageWidth
        return photo.size.height * scale + imageInsets.bottom + imageInsets.top
    }
}

extension ImagesListViewController: UITableViewDataSource {
    // Количество ячеек в таблице
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    // Получить ячейку
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            assertionFailure("[ImagesListViewController]: Could not dequeue ImagesListCell")
            return UITableViewCell()
        }
        cell.delegate = self

        let photo = photos[indexPath.row]
        cell.cellImage.image = UIImage(named: "stub")
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(named: "stub")
        ) { [weak self] result in
            guard let self else { return }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        }

        let likeName = photo.isLiked ? "LikeActive" : "LikeNoActive"
        cell.likeButton.setImage(UIImage(named: likeName), for: .normal)

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        guard let token else { return }
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage(token: token)
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]

        UIBlockingProgressHUD.show()
        guard let token else { return }
        imagesListService.changeLike(
            photoId: photo.id,
            isLike: !photo.isLiked,
            token: token) { result in
                switch result {
                case .success:
                    self.photos = self.imagesListService.photos
                    cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                    UIBlockingProgressHUD.dismiss()
                case .failure:
                    UIBlockingProgressHUD.dismiss()
                    self.showErrorAlert()
                }
            }
    }
}
