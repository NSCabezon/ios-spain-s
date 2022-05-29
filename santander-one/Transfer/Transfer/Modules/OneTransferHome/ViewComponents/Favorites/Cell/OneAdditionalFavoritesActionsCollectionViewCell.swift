import UIOneComponents
import CoreFoundationLib
import UIKit
import UI

public struct OneAdditionalFavoritesActionsViewModel {
    public enum ViewType {
        case newTransfer, newContact, newTransferSimple
        var circleImageKey: String {
            switch self {
            case .newTransfer:
                return "oneIcnPlus"
            case .newContact:
                return "oneIcnAddContact"
            case .newTransferSimple:
                return "oneIcnPlus"
            }
        }
        var titleKey: String {
            switch self {
            case .newTransfer:
                return "transfer_title_sendOptions"
            case .newContact:
                return "pg_label_newContacts"
            case .newTransferSimple:
                return "transfer_title_sendOptions"
            }
        }
        var descriptionKey: String {
            switch self {
            case .newTransfer:
                return "transfer_text_button_newSend"
            case .newContact:
                return "pg_text_addFavoriteContacts"
            case .newTransferSimple:
                return "transfer_text_button_newSend"
            }
        }
        
        var extraImageKey: String? {
            switch self {
            case .newTransfer:
                return "icnOneSendMoneyMobile"
            case .newContact:
                return nil
            case .newTransferSimple:
                return nil
            }
        }
    }
    public let viewType: ViewType
    public let accessibilityIdentifier: String?
    
    public init(viewType: ViewType, accessibilityIdentifier: String?) {
        self.viewType = viewType
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

public final class OneAdditionalFavoritesActionsCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var circleContainerView: UIView!
    @IBOutlet private weak var circleImageView: UIImageView!
    @IBOutlet private weak var mainTitleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var extraInfoStackView: UIStackView!
    @IBOutlet private weak var extraInfoLabel: UILabel!
    @IBOutlet private weak var extraImageView: UIImageView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    public func set(_ model: OneAdditionalFavoritesActionsViewModel) {
        circleImageView.image = Assets.image(named: model.viewType.circleImageKey)
        mainTitleLabel.configureText(withKey: model.viewType.titleKey)
        descriptionLabel.configureText(withKey: model.viewType.descriptionKey)
        if let extraImageKey = model.viewType.extraImageKey {
            extraInfoStackView.isHidden = false
            extraInfoLabel.configureText(withKey: "generic_text_and")
            extraImageView.image = Assets.image(named: extraImageKey)
            descriptionLabel.numberOfLines = 2
        } else {
            extraInfoStackView.isHidden = true
            descriptionLabel.numberOfLines = 3
        }
        setAccessibilityIdentifiers(model)
    }
}

private extension OneAdditionalFavoritesActionsCollectionViewCell {
    func configure() {
        contentView.backgroundColor = .oneWhite
        circleContainerView.backgroundColor = .oneBostonRed
        circleContainerView.layer.cornerRadius = 24
        mainTitleLabel.font = .typography(fontName: .oneB300Bold)
        descriptionLabel.font = .typography(fontName: .oneB200Regular)
        extraInfoLabel.font = .typography(fontName: .oneB200Regular)
        mainTitleLabel.textColor = .oneLisboaGray
        descriptionLabel.textColor = .oneLisboaGray
        extraInfoLabel.textColor = .oneLisboaGray
        layer.shadowOffset = CGSize(width: 1,
                                    height: 2)
        layer.shadowOpacity = 0.35
        layer.shadowColor = UIColor.oneLisboaGray.cgColor
        layer.shadowRadius = 4
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        layer.masksToBounds = false
    }
    
    func setAccessibilityIdentifiers(_ model: OneAdditionalFavoritesActionsViewModel) {
        circleImageView.accessibilityIdentifier = model.viewType.circleImageKey
        mainTitleLabel.accessibilityIdentifier = model.viewType.titleKey
        descriptionLabel.accessibilityIdentifier = model.viewType.descriptionKey
        circleContainerView.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyViewCircleContainer
        extraInfoLabel.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyLabelNewTransferAnd
        extraImageView.accessibilityIdentifier = model.viewType.extraImageKey
        accessibilityIdentifier = model.accessibilityIdentifier
    }
}
