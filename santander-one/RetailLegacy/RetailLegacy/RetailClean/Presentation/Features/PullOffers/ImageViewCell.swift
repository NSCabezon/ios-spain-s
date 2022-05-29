import UIKit

final class ImageViewCell: UIView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageURLView: UIImageView!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    public var modelView: ImageBannerViewModel?
    public var isRounded: Bool? = true
    
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
    
    var isClosable: Bool = false {
        didSet {
            closeButton.isHidden = !isClosable
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        imageURLView.backgroundColor = .clear
        imageURLView.contentMode = .scaleAspectFit
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.didSelectedBanner))
        imageURLView.addGestureRecognizer(gesture)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let rounded = isRounded, rounded {
            imageURLView.layer.cornerRadius = 6
            containerView.drawRoundedAndShadowed()
        }
    }
    
    @objc func didSelectedBanner(sender: UITapGestureRecognizer) {
        modelView?.selectedBanner()
    }
    
    public func onImageLoadFinished() {
        modelView?.onDrawFinished(newHeight: getNewHeight())
        
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
            newHeight += 4
            return newHeight
        }
        
        return imageURLView.frame.height
    }
    
    @IBAction func touchUpInsideCloseButton(_ sender: Any) {
          modelView?.didCloseButton()
    }
}
