import UIKit

// Класс ячейки таблицы
final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet private weak var cellImage: UIImageView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    
    // Настроить ячейку
    func configCell(with image: UIImage, dateText: String, isLiked: Bool) {
        cellImage.image = image
        dateLabel.text = dateText
        
        let likeImageName = isLiked ? "LikeActive" : "LikeNoActive"
        likeButton.setImage(UIImage(named: likeImageName), for: .normal)
    }
}
