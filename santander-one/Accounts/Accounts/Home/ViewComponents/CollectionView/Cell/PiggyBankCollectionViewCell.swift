//
//  PiggyBankCollectionViewCell.swift
//  Account
//
//  Created by David Gálvez Alonso on 01/12/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class PiggyBankCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var aliasLabel: UILabel!
    @IBOutlet private weak var ibanLabel: UILabel!
    @IBOutlet private weak var shareImageView: UIImageView!
    @IBOutlet private weak var availableAmountDescription: UILabel!
    @IBOutlet private weak var informationImageView: UIImageView!
    @IBOutlet private weak var availableAmount: UILabel!
    @IBOutlet private weak var pigImageView: UIImageView!
    
    private var viewModel: AccountViewModel?
    weak var delegate: AccountsCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.contentView.layer.borderWidth = 1.0
        self.shareImageView.image = Assets.image(named: "icnGrayShare")
        self.informationImageView.image = Assets.image(named: "icnInfoRedLight")
        self.informationImageView.isAccessibilityElement = true
        self.pigImageView.image = Assets.image(named: "imgPiggyBanksBig")
        self.setAccessibilityIdentifiers()
    }
    
    @IBAction func didTapOnInformation(_ sender: UIButton) {
        BubbleLabelView.startWith(associated: sender, text: localized("tooltip_text_calculateSavingTot"), position: .bottom)
    }
    
    @IBAction func didTapOnShared(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didTapOnShareViewModel(viewModel)
    }
}

extension PiggyBankCollectionViewCell: AccountsCollectionViewCellProtocol {
    func configure(_ viewModel: AccountViewModel) {
        self.viewModel = viewModel
        self.aliasLabel.text = viewModel.alias
        self.ibanLabel.text = viewModel.productNumber
        self.availableAmountDescription.text = localized("accountHome_label_savingTot")
        self.availableAmount.attributedText = viewModel.availableBigAmountAttributedString
        self.setDetailInfo(for: viewModel)
    }
}

private extension PiggyBankCollectionViewCell {
    func setDetailInfo(for viewModel: AccountViewModel) {
        self.viewModel = viewModel
    }

    func setAccessibilityIdentifiers() {
        aliasLabel.accessibilityIdentifier = AccessibilityAccountsHome.accountAliasPiggyBank
        ibanLabel.accessibilityIdentifier = AccessibilityAccountsHome.accountIbanPiggyBank
        availableAmountDescription.accessibilityIdentifier = AccessibilityAccountsHome.accountHomeLabelSavingTot
        availableAmount.accessibilityIdentifier = AccessibilityAccountsHome.accountImportPiggyBank
        pigImageView.accessibilityIdentifier = AccessibilityAccountsHome.imgPiggyBanksBig
        shareImageView.accessibilityIdentifier = AccessibilityAccountsHome.icnGrayShare
        informationImageView.accessibilityIdentifier = AccessibilityAccountsHome.icnInfoRedLight
    }
}
