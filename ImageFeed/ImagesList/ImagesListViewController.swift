import UIKit

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView! // Таблица-лента
    private let photosName: [String] = Array(0..<20).map { "\($0)" } // Названия mock-фотографий
    private let showSingleImageSegueIdentifier = "ShowSingleImage" // Идентификатор перехода
    
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
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                return
            }
            
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
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
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        
        if imageWidth == 0 { return 200 }
        let scale = imageViewWidth / imageWidth
        return image.size.height * scale + imageInsets.bottom + imageInsets.top
    }
}

extension ImagesListViewController: UITableViewDataSource {
    // Количество ячеек в таблице
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    // Получить ячейку
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        if let image = UIImage(named: photosName[indexPath.row]) {
            let dateText = dateFormatter.string(from: Date())
            let isLiked = (indexPath.row % 2 == 0)
            
            imagesListCell.configCell(with: image, dateText: dateText, isLiked: isLiked)
        }
        
        return imagesListCell
    }
}
