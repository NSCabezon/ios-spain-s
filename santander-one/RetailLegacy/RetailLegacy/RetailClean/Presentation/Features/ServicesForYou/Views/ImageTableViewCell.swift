import UIKit

class ImageTableViewCell: BaseViewCell {
    @IBOutlet weak var imageURLView: UIImageView!
        
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingContraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var insets: UIEdgeInsets? {
        didSet {
            if let insets = insets {
                leadingContraint.constant = insets.left
                trailingConstraint.constant = insets.right
                topConstraint.constant = insets.top
                bottomConstraint.constant = insets.bottom
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageURLView.translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    public func onImageLoadFinished() {            
        setNeedsLayout()
        layoutIfNeeded()
        layoutSubviews()
    }
    
    private func getNewHeight() -> CGFloat {
        if let imageSize = imageURLView.image?.size {
            let deviceWidth = imageURLView.frame.width
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
