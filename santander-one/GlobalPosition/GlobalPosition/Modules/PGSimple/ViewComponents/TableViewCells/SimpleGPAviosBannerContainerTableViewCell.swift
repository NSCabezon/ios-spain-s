import UIKit
import UI

final class SimpleGPAviosBannerContainerTableViewCell: UITableViewCell {
    @IBOutlet private weak var aviosContainerView: AviosBanner!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        contentView.backgroundColor = .skyGray
        aviosContainerView.backgroundColor = .white
        aviosContainerView.drawBorder(cornerRadius: 6, color: .mediumSkyGray, width: 1)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                          verticalFittingPriority: UILayoutPriority) -> CGSize {
        self.layoutIfNeeded()
        return CGSize(width: targetSize.width, height: aviosContainerView.calculatedHeight)
    }
}
