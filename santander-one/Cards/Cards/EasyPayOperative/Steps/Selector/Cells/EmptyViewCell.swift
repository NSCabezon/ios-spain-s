import UIKit
import CoreFoundationLib
import UI

final class EmptyViewCell: UITableViewCell {
    
    @IBOutlet weak var snowImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        snowImage.image = Assets.image(named: "icnNoMovement")
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 340.0)
    }
}

private extension EmptyViewCell {
    func setInfoText(_ info: LocalizedStylableText) {
        infoLabel.configureText(withLocalizedString: info)
    }
    
    func setTitleText(_ title: LocalizedStylableText?) {
        guard let title = title else { return titleLabel.isHidden = true }
        titleLabel.configureText(withLocalizedString: title)
        titleLabel.isHidden = false
    }
    
    func applyStyle(style: EmptyViewStyle) {
        switch style {
        case .normal:
            if titleLabel.isHidden {
                configureLabel(infoLabel, color: .lightSanGray, font: UIFont.santander(type: .bold, size: 16.0), alignment: .center)
            } else {
                configureLabel(titleLabel, color: .mediumSanGray, font: UIFont.santander(type: .bold, size: 16.0), alignment: .center)
                configureLabel(infoLabel, color: .sanGreyDark, font: UIFont.santander(type: .light, size: 14.0), alignment: .center)
            }
        case .globalPosition:
            configureLabel(infoLabel, color: .sanGreyDark, font: UIFont.santander(type: .light, size: 14.0), alignment: .center)
        }
    }
    
    func configureLabel(_ label: UILabel,
                        color: UIColor,
                        font: UIFont,
                        alignment: NSTextAlignment) {
        label.textColor = color
        label.font = font
        label.textAlignment = alignment
    }
}

extension EmptyViewCell: EasyPayTableViewCellProtocol {
    func setCellInfo(_ info: Any) {
        guard let info = info as? EmptyViewModelView else { return }
        applyStyle(style: info.style)
        setInfoText(info.text)
        setTitleText(info.title)
    }
}
