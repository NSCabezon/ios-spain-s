//
//  AccountsHeaderTableViewCell.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 30/6/21.
//

import UIKit
import CoreFoundationLib
import UI

protocol AccountsHeaderTableViewCellDelegate: AnyObject {
    func didPressAllAccountsCheckBox(_ isSelected: Bool)
}

class AccountsHeaderTableViewCell: UITableViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var checkBoxImage: UIImageView!
    @IBOutlet private weak var checkBoxButton: UIButton!
    private var viewModel: BasketHeaderCellViewModel?
    weak var delegate: AccountsHeaderTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setViewModel(_ viewModel: BasketHeaderCellViewModel) {
        self.viewModel = viewModel
        self.setCheckBoxImage()
    }
    
    @IBAction private func didPressCheckBox(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didPressAllAccountsCheckBox(!viewModel.areAllSelected)
    }
}

private extension AccountsHeaderTableViewCell {
    func setupView() {
        self.setContainerView()
        self.setTitleLabel()
        self.setCheckBoxImage()
        self.setAccessibilityIdentifiers()
    }
    
    func setContainerView() {
        self.containerView.drawBorder(cornerRadius: 6, color: .lightSkyBlue, width: 1)
        self.containerView.layer.masksToBounds = true
        if #available(iOS 11.0, *) {
            self.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            self.containerView.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        }
    }
    
    func setTitleLabel() {
        self.title.text = localized("pgBasket_title_accounts")
        self.title.setSantanderTextFont(type: .bold, size: 16, color: .lisboaGray)
    }
    
    func setCheckBoxImage() {
        let isSelected = self.viewModel?.areAllSelected ?? true
        self.checkBoxImage.image = isSelected ? Assets.image(named: "icnCheckBoxSelectedGreen") : Assets.image(named: "icnCheckBoxUnSelectedGreen")
    }
    
    func setAccessibilityIdentifiers() {
        self.title.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.accountsHeaderLabel
        self.checkBoxImage.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.accountsHeaderCheckBox
    }
}
