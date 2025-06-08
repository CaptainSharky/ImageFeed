import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func insertRows(at indexPaths: [IndexPath])
    func showError(message: String)
    func setLoading(_ isLoading: Bool)
    func updateLike(at index: Int, isLiked: Bool)
    func reloadTableData()
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    @IBOutlet private var tableView: UITableView!
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        presenter = ImagesListPresenter(view: self)
        presenter?.viewDidLoad()
    }

    func insertRows(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func reloadTableData() {
        tableView.reloadData()
    }

    func showError(message: String) {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: message,
            preferredStyle: .alert
        )
        let okayButton = UIAlertAction(title: "Ок", style: .default)
        alert.addAction(okayButton)
        present(alert, animated: true)
    }

    func setLoading(_ isLoading: Bool) {
        if isLoading {
            UIBlockingProgressHUD.show()
        } else {
            UIBlockingProgressHUD.dismiss()
        }
    }

    func updateLike(at index: Int, isLiked: Bool) {
        let indexPath = IndexPath(row: index, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else { return }
        cell.setIsLiked(isLiked: isLiked)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                return
            }
            
            guard let photoURL = presenter?.getPhotoURL(at: indexPath.row) else { return }
            viewController.fullImageURL = photoURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
        let viewModel = presenter?.cellViewModel(for: indexPath.row)
        guard let viewModel else { return 200 }

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = viewModel.imageSize.width

        guard imageWidth > 0 else { return 200 }
        let scale = imageViewWidth / imageWidth
        return viewModel.imageSize.height * scale + imageInsets.bottom + imageInsets.top
    }
}

extension ImagesListViewController: UITableViewDataSource {
    // Количество ячеек в таблице
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { presenter?.numberOfPhotos ?? 0 }

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

        let viewModel = presenter?.cellViewModel(for: indexPath.row)
        guard let viewModel else { return cell }
        cell.cellImage.image = UIImage(resource: .stub)
        cell.cellImage.kf.indicatorType = .activity
        if let url = viewModel.thumbURL {
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: UIImage(resource: .stub)
            )
        }
        cell.dateLabel.text = viewModel.date
        cell.setIsLiked(isLiked: viewModel.isLiked)

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        presenter?.willDisplayRow(at: indexPath.row)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath.row)
    }
}
