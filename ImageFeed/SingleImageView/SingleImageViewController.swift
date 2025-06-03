import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var fullImageURL: URL?

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Значения для зума scrollView
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25

        setImage()
    }

    private func setImage() {
        guard let fullImageURL else { return }

        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: fullImageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self else { return }
            switch result {
            case .success(let imageResult):
                self.imageView.frame.size = imageResult.image.size
                self.rescaleAndCenterImageScrollView(image: imageResult.image)
            case .failure:
                self.showErrorAlert()
            }
        }
    }

    // Алгоритм рескейла фотографии
    private func rescaleAndCenterImageScrollView(image: UIImage) {
        view.layoutIfNeeded()
        
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        
        centerImage()
    }
    
    // Отцентровать изображение
    private func centerImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageSize = imageView.frame.size
        
        let verticalInset = max(0, (scrollViewSize.height - imageSize.height) / 2)
        let horizontalInset = max(0, (scrollViewSize.width - imageSize.width) / 2)
        
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }

    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        let noNeedButton = UIAlertAction(title: "Не надо", style: .cancel)
        let tryAgainButton = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.setImage()
        }
        alert.addAction(noNeedButton)
        alert.addAction(tryAgainButton)
        self.present(alert, animated: true)
    }

    // Нажал кнопку "<"
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Нажал кнопку "Поделиться"
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
