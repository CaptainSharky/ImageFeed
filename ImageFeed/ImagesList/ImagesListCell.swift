import UIKit
import Kingfisher

// Класс ячейки таблицы
final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    // Настроить ячейку
//    func configCell(with image: UIImage, dateText: String, isLiked: Bool) {
//        cellImage.image = image
//        dateLabel.text = dateText
//        
//        let likeImageName = isLiked ? "LikeActive" : "LikeNoActive"
//        likeButton.setImage(UIImage(named: likeImageName), for: .normal)
//    }
    func setIsLiked(isLiked: Bool) {
        let likeImageName = isLiked ? "LikeActive" : "LikeNoActive"
        likeButton.setImage(UIImage(named: likeImageName), for: .normal)
    }

    @IBAction func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
