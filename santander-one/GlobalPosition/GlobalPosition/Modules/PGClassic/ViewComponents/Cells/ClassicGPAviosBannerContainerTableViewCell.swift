import UIKit
import UI

final class ClassicGPAviosBannerContainerTableViewCell: UITableViewCell {
    @IBOutlet private weak var aviosContainerView: AviosBanner!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        contentView.backgroundColor = .skyGray
        aviosContainerView.backgroundColor = .white
        aviosContainerView.drawBorder(cornerRadius: 6, color: .mediumSkyGray, width: 1)
    }
}
