//

import UIKit
import UI

class CustomizeAppToolTipTableCell: SpaceGroupableTableViewCell {
    var title: LocalizedStylableText? {
        didSet {
            if let title = title {
                titleLabel.set(localizedStylableText: title)
            } else {
                titleLabel.text = nil
            }
        }
    }
        
    var iconButtonTouched: (() -> Void)?
        
    override var roundedView: UIView {
        return containerView
    }
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16.0)))
        iconView.image = Assets.image(named: "icnInfoGrayBig")
    }
    
    func showToolTip(description: LocalizedStylableText, inPresenter presenter: ToolTipablePresenter, forcedDirection: UIPopoverArrowDirection?) {
        ToolTip.displayToolTip(title: nil,
                               description: nil,
                               descriptionLocalized: description,
                               sourceView: iconView,
                               sourceRect: iconView.bounds,
                               backView: presenter.toolTipBackView,
                               forcedDirection: forcedDirection)
    }
    
    @IBAction func iconButtonTouched(_ sender: UIButton) {
        iconButtonTouched?()
    }
}
