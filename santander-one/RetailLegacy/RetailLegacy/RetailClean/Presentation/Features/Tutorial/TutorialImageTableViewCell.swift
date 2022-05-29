//

import UIKit

class TutorialImageTableViewCell: BaseViewCell {
    @IBOutlet weak var imageURLView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    public var modelView: TutorialImageTableViewModel?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        modelView?.willReuseView(viewCell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        containerView.backgroundColor = .clear
        imageURLView.backgroundColor = .clear
    }
    
    func finishDownload() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: modelView?.height ?? 130)
    }
}
