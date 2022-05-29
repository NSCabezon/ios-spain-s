import UIKit

protocol CollectionViewModel {
    associatedtype CollectionCell: UICollectionViewCell
    func bind(viewCell: CollectionCell)
}

class CreativityCarouselCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var modelView: CreativityCarouselCollectionViewModel?
    
    var insets: UIEdgeInsets? {
        didSet {
            if let insets = insets {
                leadingConstraint.constant = insets.left
                trailingConstraint.constant = insets.right
                topConstraint.constant = insets.top
                bottomConstraint.constant = insets.bottom
            }
        }
    }
    
    func onImageLoadFinished() {
        modelView?.onDrawFinished(newHeight: getNewHeight())
        
        setNeedsLayout()
        layoutIfNeeded()
        layoutSubviews()
    }
    
    private func getNewHeight() -> CGFloat {
        if let imageSize = imageView.image?.size {
            let deviceWidth = imageView.frame.width
            let imageAspectRatio = imageSize.height / imageSize.width
            var newHeight = imageAspectRatio * deviceWidth
            if let bottom = self.insets?.bottom {
                newHeight += bottom
            }
            if let top = self.insets?.top {
                newHeight += top
            }
            return newHeight
        }
        
        return 0
    }
}
