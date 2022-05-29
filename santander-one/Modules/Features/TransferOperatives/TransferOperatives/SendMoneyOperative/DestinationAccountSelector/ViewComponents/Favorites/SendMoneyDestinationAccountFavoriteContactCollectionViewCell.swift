//
//  SendMoneyDestinationAccountFavoriteContactCollectionViewCell.swift
//  TransferOperatives
//
//  Created by Angel Abad Perez on 27/9/21.
//

import UIOneComponents
import CoreFoundationLib

final class SendMoneyDestinationAccountFavoriteContactCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var favoriteContactCard: OneFavoriteContactCardView!
    private var viewModel: OneFavoriteContactCardViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    func setViewModel(_ viewModel: OneFavoriteContactCardViewModel) {
        self.viewModel = viewModel
        self.favoriteContactCard.setupFavoriteContactViewModel(viewModel)
    }

    func setAccessibilitySuffix(_ suffix: String) {
        self.favoriteContactCard.setAccessibilitySuffix(suffix)
    }
    
    func setAccessibilityCell() {
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
}

private extension SendMoneyDestinationAccountFavoriteContactCollectionViewCell {
    func setupView() {
        self.clipsToBounds = false
        self.contentView.isUserInteractionEnabled = false
    }
    
    func setAccessibilityInfo() {
        self.isAccessibilityElement = true
        self.accessibilityLabel = self.setCardAccessibilityLabel()
        self.accessibilityTraits = .button
        self.accessibilityHint = viewModel?.cardStatus != .selected ? self.setAccessibilityHint() : nil
        return
    }
    
    func setCardAccessibilityLabel() -> String {
        let lastNumber = viewModel?.shortIBAN.dropFirst().map { String($0) + " " }.joined()
        let isSelected = viewModel?.cardStatus == .selected ? localized("voiceover_selected").text : localized("voiceover_unselected").text
        let label: String = """
            \(viewModel?.name ?? "")
            \(localized("voiceover_accountEnds", [.init(.value, lastNumber ?? "")]).text)
            \(isSelected)
        """
        return label
    }
    
    func setAccessibilityHint() -> String {
        let tapTwice = localized("voiceover_tapTwiceTo").text
        let to = localized("voiceover_selectAndForward").text
        let hint = "\(tapTwice) \(to)"
        return hint
    }
}

extension SendMoneyDestinationAccountFavoriteContactCollectionViewCell: AccessibilityCapable {}
