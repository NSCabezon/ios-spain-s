import UIKit

class LocationBannerTableViewCell: BaseViewCell {
    @IBOutlet weak var imageURLView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    public var modelView: LocationBannerViewModel?
        
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        modelView?.willReuseView(viewCell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageURLView.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        imageURLView.superview?.backgroundColor = .clear
        imageURLView.backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        modelView?.onDrawFinished(newHeight: getNewHeight())
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
            return newHeight
        }
        
        return 0
    }
    
    @IBAction func touchUpInsideCloseButton(_ sender: Any) {
        modelView?.didCloseButton()
    }
}
