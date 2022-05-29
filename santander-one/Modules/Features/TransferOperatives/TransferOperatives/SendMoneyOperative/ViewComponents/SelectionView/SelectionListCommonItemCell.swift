//
//  SelectionListCommonItemCell.swift
//  TransferOperatives
//
//  Created by Angel Abad Perez on 11/1/22.
//

import UI
import CoreFoundationLib

final class SelectionListCommonItemCell: UICollectionViewCell {
    private enum Constants {
        static let cornerIconName: String = "icnCheckOvalGreen"
    }
        
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var mainIconImageView: UIImageView!
    @IBOutlet private weak var cornerIconImageView: UIImageView!
    @IBOutlet private weak var mainView: UIView!
    
    private var status: OneSmallSelectorListViewModel.Status = .inactive
    private var selectionType: SelectionListView.SelectionType = .countries
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }
    
    func setViewModel(_ viewModel: OneSmallSelectorListViewModel, type: SelectionListView.SelectionType) {
        self.status = viewModel.status
        self.selectionType = type
        self.configureByStatus()
        self.configureByAccessory(viewModel.rightAccessory)
        self.setSubtitleLabelText(viewModel.leftTextKey)
        self.setAccessibilityIdentifiers(suffix: viewModel.accessibilitySuffix)
    }
    
    func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix: suffix)
    }
}

private extension SelectionListCommonItemCell {
    func configureView() {
        self.configureViews()
        self.configureLabels()
        self.configureImageViews()
        self.configureAccessories()
        self.setAccessibilityIdentifiers()
    }
    
    func configureViews() {
        self.mainView.setOneCornerRadius(type: .oneShRadius8)
        self.mainView.setOneShadows(type: .oneShadowLarge)
    }
    
    func configureLabels() {
        self.titleLabel.font = .typography(fontName: .oneH200Bold)
        self.titleLabel.textColor = .oneDarkTurquoise
        self.subtitleLabel.font = .typography(fontName: .oneB300Regular)
        self.subtitleLabel.textColor = .oneLisboaGray
    }
    
    func configureImageViews() {
        self.cornerIconImageView.image = Assets.image(named: Constants.cornerIconName)
    }
    
    func configureAccessories() {
        self.mainIconImageView.isHidden = true
        self.titleLabel.isHidden = true
        self.cornerIconImageView.isHidden = true
    }
    
    func configureByStatus() {
        self.mainView.backgroundColor = self.status.backgroundColor
        self.mainView.setOneShadows(type: self.status == .activated ? .none : .oneShadowLarge)
        self.subtitleLabel.textColor = self.status.leftTextColor
        self.subtitleLabel.font = self.status.leftTextFont
        self.cornerIconImageView.isHidden = self.status != .activated
    }
    
    func configureByAccessory(_ type: OneSmallSelectorListViewModel.RightAccessory) {
        switch type {
        case .text(let textKey):
            self.titleLabel.isHidden = false
            self.titleLabel.text = localized(textKey)
        case .icon(let imageName):
            self.mainIconImageView.isHidden = false
            if let image = Assets.image(named: imageName) {
                self.mainIconImageView.image = image
            } else {
                self.mainIconImageView.loadImage(urlString: imageName)
            }
        case .none:
            break
        }
    }
    
    func setSubtitleLabelText(_ textKey: String) {
        self.subtitleLabel.text = localized(textKey)
    }
    
    func setAccessibilityIdentifiers(suffix: String? = nil) {
        switch self.selectionType {
        case .countries:
            self.subtitleLabel.accessibilityIdentifier = AccessibilitySendMoneyDestination.ChangeCountryView.chooseCountrySelectorCardLabel + (suffix ?? "")
            self.mainIconImageView.accessibilityIdentifier = AccessibilitySendMoneyDestination.ChangeCountryView.chooseCountrySelectorCardFlag + (suffix ?? "")
            self.cornerIconImageView.accessibilityIdentifier = AccessibilitySendMoneyDestination.ChangeCountryView.icnCheck + (suffix ?? "")
            self.mainView.accessibilityIdentifier = AccessibilitySendMoneyDestination.ChangeCountryView.chooseCountrySelectorCardView + (suffix ?? "")
        case .currencies:
            self.subtitleLabel.accessibilityIdentifier = AccessibilitySendMoneyAmount.ChangeCurrencyView.chooseCurrencySelectorCardCurrencyLabel + (suffix ?? "")
            self.titleLabel.accessibilityIdentifier = AccessibilitySendMoneyAmount.ChangeCurrencyView.chooseCurrencySelectorCardCurrencyTitle + (suffix ?? "")
            self.cornerIconImageView.accessibilityIdentifier = AccessibilitySendMoneyAmount.ChangeCurrencyView.icnCheck + (suffix ?? "")
            self.mainView.accessibilityIdentifier = AccessibilitySendMoneyAmount.ChangeCurrencyView.chooseCurrencySelectorCardView + (suffix ?? "")
        }
    }
}

extension SelectionListCommonItemCell: AccessibilityCapable {}
