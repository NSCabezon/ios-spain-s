import UIKit
import UI

class ChangeLogIconViewCellItem: BaseViewCell {
    
    var iconImageName: String? {
        didSet {
            if let iconName = iconImageName {
                iconImage.image = Assets.image(named: iconName)
            }
        }
    }
    
    var title: String? {
        didSet {
            if let title = title {
                titleLabel.text = title
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    var buttonText: String? {
        didSet {
            if let buttonText = buttonText {
                updateButton.setTitle(buttonText.uppercased(), for: .normal)
            } else {
                updateButton.setTitle(nil, for: .normal)
            }
        }
    }
    
    var showUpgradeButton: Bool = false {
        didSet {
            updateButton.isHidden = !showUpgradeButton
        }
    }
    
    var buttonCallback: (() -> Void)?
    
    @IBOutlet private weak var iconImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var updateButton: ColorButton!

    override func awakeFromNib() {
        iconImage.contentMode = .scaleAspectFit
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 18.0)))
        
        let styleButton = ButtonStylist(textColor: .sanRed, font: .latoSemibold(size: 13), borderColor: .sanRed, borderWidth: 1, backgroundColor: .clear)
        let styleButtonSelected = ButtonStylist(textColor: .sanRed, font: .latoSemibold(size: 13), borderColor: .sanRed, borderWidth: 1, backgroundColor: .clear)
        updateButton.applyHighlightedStylist(normal: styleButton, selected: styleButtonSelected)
        updateButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 15, bottom: 7, right: 15)

        backgroundColor = .clear
        selectionStyle = .none
    }
    
    @IBAction func onButtonClicked(_ sender: Any) {
        if let callback = buttonCallback {
            callback()
        }
    }
}
