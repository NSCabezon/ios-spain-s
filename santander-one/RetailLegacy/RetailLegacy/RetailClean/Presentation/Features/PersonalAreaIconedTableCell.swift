import UIKit
import UI

enum PersonalAreaIcon {
    case pendingPayments
    
    var image: UIImage? {
        let name: String
        switch self {
        case .pendingPayments:
            name = "icnPendingPays"
        }
        return Assets.image(named: name)
    }
}

class PersonalAreaIconedTableCell: SpaceGroupableTableViewCell {
    
    var icon: PersonalAreaIcon? {
        didSet {
            iconView.image = icon?.image
        }
    }
    var title: LocalizedStylableText? {
        didSet {
            if let title = title {
                titleLabel.set(localizedStylableText: title)
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    override var roundedView: UIView {
        return containerView
    }
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16.0)))
    }
}
