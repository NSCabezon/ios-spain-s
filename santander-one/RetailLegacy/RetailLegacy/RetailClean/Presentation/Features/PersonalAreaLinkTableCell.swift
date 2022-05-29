import UIKit

class PersonalAreaLinkTableCell: SpaceGroupableTableViewCell {
    
    var title: LocalizedStylableText? {
        didSet {
            if let title = title {
                titleLabel.set(localizedStylableText: title)
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    var value: String? {
        get {
            return valueLabel.text
        }
        set {
            valueLabel.text = newValue
        }
    }
    
    override var roundedView: UIView {
        return containerView
    }
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16.0)))
        valueLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 16.0)))
    }
}
