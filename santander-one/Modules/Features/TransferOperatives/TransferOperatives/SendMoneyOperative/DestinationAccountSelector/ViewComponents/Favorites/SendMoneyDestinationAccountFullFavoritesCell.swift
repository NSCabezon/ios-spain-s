//
//  SendMoneyDestinationAccountFullFavoritesCell.swift
//  TransferOperatives
//
//  Created by Angel Abad Perez on 30/9/21.
//

import UIOneComponents
import CoreFoundationLib

final class SendMoneyDestinationAccountFullFavoritesCell: UITableViewCell {
    @IBOutlet private weak var avatarView: OneAvatarView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var ibanLabel: UILabel!
    @IBOutlet private weak var bankImageView: UIImageView!
    private var viewModel:OneFavoriteContactCardViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCell()
    }
    
    func configure(with viewModel: OneFavoriteContactCardViewModel, highlightedText: String?) {
        self.viewModel = viewModel
        self.setAvatar(from: viewModel)
        self.setLabelTexts(from: viewModel, highlightedText: highlightedText)
        self.setBankImage(from: viewModel)
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }

    func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
}

private extension SendMoneyDestinationAccountFullFavoritesCell {
    func setupCell() {
        self.accessoryType = .none
        self.selectionStyle = .none
        self.configureLabels()
        self.setAccessibilityIdentifiers()
    }
    
    func configureLabels() {
        self.nameLabel.font = .typography(fontName: .oneB400Regular)
        self.nameLabel.textColor = .oneLisboaGray
        self.ibanLabel.font = .typography(fontName: .oneB300Regular)
        self.ibanLabel.textColor = .oneBrownishGray
    }
    
    func setAvatar(from viewModel: OneFavoriteContactCardViewModel) {
        self.avatarView.setupAvatar(viewModel.avatar)
    }
    
    func setLabelTexts(from viewModel: OneFavoriteContactCardViewModel, highlightedText: String?) {
        let attributedString = NSMutableAttributedString(string: viewModel.name)
        if let highlightedText = highlightedText,
           !highlightedText.isEmpty,
           let highlightedRange = viewModel.name.lowercased().range(of: highlightedText) {
            attributedString.addAttribute(.backgroundColor,
                                          value: UIColor.onePaleYellow,
                                          range: NSRange(highlightedRange, in: viewModel.name))
        }
        self.nameLabel.attributedText = attributedString
        self.ibanLabel.text = viewModel.ibanPapel
    }
    
    func setBankImage(from viewModel: OneFavoriteContactCardViewModel) {
        if let logoUrl = viewModel.bankLogoURL {
            self.bankImageView.loadImage(urlString: logoUrl) { [weak self] in
                self?.bankImageView.isHidden = (self?.bankImageView.image == nil)
            }
        }
    }

    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.avatarView.setAccessibilitySuffix(suffix ?? "")
        self.nameLabel.accessibilityIdentifier = AccessibilitySendMoneyDestination.AllFavorites.cellNameLabel + (suffix ?? "")
        self.ibanLabel.accessibilityIdentifier = AccessibilitySendMoneyDestination.AllFavorites.cellIBANLabel + (suffix ?? "")
        self.bankImageView.accessibilityIdentifier = AccessibilitySendMoneyDestination.AllFavorites.cellBankLogo + (suffix ?? "")
    }
    
    func setAccessibilityInfo() {
        self.contentView.isAccessibilityElement = true
        self.contentView.accessibilityLabel = "\(self.viewModel?.name ?? ""). \(self.viewModel?.ibanPapel ?? "")"
    }
}

extension SendMoneyDestinationAccountFullFavoritesCell: AccessibilityCapable {}
