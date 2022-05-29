//
//  OneAccountSelectionCardView.swift
//  Account
//
//  Created by David Gálvez Alonso on 24/08/2021.
//

import UI
import CoreFoundationLib

public final class OneAccountSelectionCardView: XibView {
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var checkView: UIImageView!
    @IBOutlet private weak var heartView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var helperLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var dashedLineView: DashedLineView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }
    
    public func setupAccountItem(_ item: OneAccountSelectionCardItem,
                                 itemsList: [OneAccountSelectionCardItem] = []) {
        self.configureByStatus(item.cardStatus)
        self.setLabelText(item)
        self.setAccessibilitySuffix(item.accessibilitySuffix ?? "")
        self.setAccessibility {
            self.setAccessibilityInfo(item)
        }
    }

    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
}


private extension OneAccountSelectionCardView {
    func configureView() {
        self.configureViews()
        self.configureLabels()
        self.configureImageViews()
        self.setAccessibilityIdentifiers()
    }
    
    func configureViews() {
        self.dashedLineView.strokeColor = .oneMediumSkyGray
        self.contentView.setOneCornerRadius(type: .oneShRadius8)
    }
    
    func configureLabels() {
        self.titleLabel.font = .typography(fontName: .oneH100Bold)
        self.descriptionLabel.font = .typography(fontName: .oneB300Regular)
        self.helperLabel.font = .typography(fontName: .oneB200Regular)
    }
    
    func configureImageViews() {
        self.heartView.image = Assets.image(named: "icnHeartSelected")?.withRenderingMode(.alwaysTemplate)
        self.heartView.tintColor = UIColor.oneDarkTurquoise
        self.checkView.image = Assets.image(named: "icnCheckOvalGreen")
    }
    
    func configureByStatus(_ status: OneAccountSelectionCardItem.CardStatus) {
        self.contentView.backgroundColor = status.backgroundColor()
        let textColor = status.itemsColor()
        self.titleLabel.textColor = textColor
        self.descriptionLabel.textColor = textColor
        self.helperLabel.textColor = textColor
        self.amountLabel.textColor = textColor
        self.heartView.isHidden = status != .favourite
        self.checkView.isHidden = status != .selected
        if status == .inactive {
            self.contentView.setOneShadows(type: .oneShadowLarge)
        }
        self.view?.isUserInteractionEnabled = true
    }
    
    func setLabelText(_ viewModel: OneAccountSelectionCardItem) {
        self.titleLabel.text = viewModel.title
        self.descriptionLabel.text = viewModel.description
        self.helperLabel.text = viewModel.localizedHelperText
        self.amountLabel.attributedText = viewModel.formattedAmount
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.contentView.accessibilityIdentifier = AccessibilityOneComponents.oneAccountSelectionCardView + (suffix ?? "")
        self.titleLabel.accessibilityIdentifier = AccessibilityOneComponents.oneAccountSelectionCardTitle + (suffix ?? "")
        self.descriptionLabel.accessibilityIdentifier = AccessibilityOneComponents.oneAccountSelectionCardDescription + (suffix ?? "")
        self.helperLabel.accessibilityIdentifier = AccessibilityOneComponents.oneAccountSelectionCardHelper + (suffix ?? "")
        self.amountLabel.accessibilityIdentifier = AccessibilityOneComponents.oneAccountSelectionCardAmount + (suffix ?? "")
        self.checkView.accessibilityIdentifier = AccessibilityOneComponents.oneAccountSelectionCardCheckIcn + (suffix ?? "")
        self.heartView.accessibilityIdentifier = AccessibilityOneComponents.oneAccountSelectionCardFavoriteIcn + (suffix ?? "")
    }
    
    func setAccessibilityInfo(_ viewModel: OneAccountSelectionCardItem) {
        self.contentView.isAccessibilityElement = true
        let actionText = localized("voiceover_tapTwiceTo") + " " + (viewModel.cardStatus == .selected ? localized("voiceover_forward") : localized("voiceover_selectAndForward"))
        self.contentView.accessibilityHint = actionText
        let isSelectedText: String = viewModel.cardStatus == .selected ? localized("voiceover_selected") : localized("voiceover_unselected")
        let aliasText: String = localized("voiceover_accountAlias", [.init(.value, viewModel.title)]).text
        let contentLabel = [aliasText, isSelectedText]
        self.contentView.accessibilityLabel = contentLabel.joined(separator: ", ")
        self.titleLabel.accessibilityLabel = viewModel.title
        if #available(iOS 13.0, *) {
            self.descriptionLabel.accessibilityAttributedLabel = NSAttributedString(string: viewModel.description.replacingOccurrences(of: " ", with: ""), attributes:[.accessibilitySpeechSpellOut: true])
        } else {
            self.descriptionLabel.accessibilityLabel = viewModel.description
        }
        self.helperLabel.accessibilityLabel = localized("account_label_transferBalance")
        self.amountLabel.accessibilityLabel = viewModel.amountRepresentable?.getAccessibilityAmountText()
        self.accessibilityElements = [self.contentView, titleLabel, descriptionLabel, helperLabel, amountLabel].compactMap{ $0 }
    }
}

extension OneAccountSelectionCardView: AccessibilityCapable {}
