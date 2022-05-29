//
//  AccountProductConfigTableViewCell.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 1/7/21.
//

import UI
import CoreFoundationLib

protocol AccountProductConfigCellDelegate: AnyObject {
    func didPressAccountCheckBox(_ viewModel: AccountProductConfigCellViewModel)
}

final class AccountProductConfigTableViewCell: UITableViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var aliasLabel: UILabel!
    @IBOutlet private weak var ibanLabel: UILabel!
    @IBOutlet private weak var bankImageView: UIImageView!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var checkBoxImageView: UIImageView!
    @IBOutlet private weak var dotsSeparatorView: DottedLineView!
    @IBOutlet private weak var lastCellTopSeparatorView: UIView!
    weak var delegate: AccountProductConfigCellDelegate?
    private var viewModel: AccountProductConfigCellViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setViewModel(_ viewModel: AccountProductConfigCellViewModel) {
        self.viewModel = viewModel
        self.setLabelsText(viewModel)
        self.setBankImage(viewModel)
        self.setCheckBoxImage()
        self.setLastCell(viewModel.isLastCell)
    }
    
    @IBAction private func didPressCheckBox(_ sender: Any) {
        guard var viewModel = self.viewModel else { return }
        viewModel.setIsCellSelected(isSelected: !viewModel.isSelected)
        self.delegate?.didPressAccountCheckBox(viewModel)
    }
}

private extension AccountProductConfigTableViewCell {
    func setupView() {
        self.dotsSeparatorView.strokeColor = .lightSkyBlue
        self.lastCellTopSeparatorView.backgroundColor = self.containerView.backgroundColor
        self.lastCellTopSeparatorView.isHidden = true
        self.containerView.borders(for: [.left, .right], width: 1, color: .lightSkyBlue)
        self.aliasLabel.setSantanderTextFont(type: .bold, size: 16, color: .lisboaGray)
        self.ibanLabel.setSantanderTextFont(type: .light, size: 14, color: .lisboaGray)
        self.amountLabel.setSantanderTextFont(color: .lisboaGray)
    }
    
    func setLabelsText(_ viewModel: AccountProductConfigCellViewModel) {
        self.aliasLabel.text = viewModel.name
        self.ibanLabel.text = viewModel.iban
        self.amountLabel.attributedText = viewModel.amount
    }
    
    func setBankImage(_ viewModel: AccountProductConfigCellViewModel) {
        if let bankIconUrl = viewModel.bankIconUrl {
            // TODO: - Remove default image when service is working
            self.bankImageView.loadImage(urlString: bankIconUrl,
                                         placeholder: Assets.image(named: "icnSantander"))
        } else {
            self.bankImageView.image = nil
        }
    }
    
    func setCheckBoxImage() {
        let isSelected = self.viewModel?.isSelected ?? true
        self.checkBoxImageView.image = isSelected ? Assets.image(named: "icnCheckBoxSelectedGreen") : Assets.image(named: "icnCheckBoxUnSelectedGreen")
    }
    
    func setLastCell(_ isLastCell: Bool) {
        guard isLastCell else { return }
        self.dotsSeparatorView.isHidden = true
        self.lastCellTopSeparatorView.isHidden = false
        self.containerView.drawBorder(cornerRadius: 6, color: .lightSkyBlue, width: 1)
        self.containerView.layer.masksToBounds = true
        if #available(iOS 11.0, *) {
            self.containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            self.containerView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
        }
    }
    
    func setAccessibilityIdentifiers() {
        self.aliasLabel.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.accountNameLabel
        self.ibanLabel.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.accountIbanLabel
        self.amountLabel.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.accountAmountLabel
        self.bankImageView.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.accountBankImage
        self.checkBoxImageView.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.accountCheckBox
    }
}
