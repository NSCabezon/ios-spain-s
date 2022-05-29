//
//  AccountSelectionTableViewCell.swift
//  Bills
//
//  Created by Carlos Monfort Gómez on 20/05/2020.
//

import UIKit
import CoreFoundationLib

public class AccountSelectionTableViewCell: UITableViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var accountTitleLabel: UILabel!
    @IBOutlet private weak var accountNumberLabel: UILabel!
    @IBOutlet private weak var availableAmountTitleLabel: UILabel!
    @IBOutlet private weak var availableAmountLabel: UILabel!
    
    public static var identifier: String {
        return String(describing: self)
    }
    
    public static var bundle: Bundle? {
        return .module
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setAppearance()
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        self.containerView.drawRoundedAndShadowedNew(radius: 5.0, borderColor: .lightSkyBlue)
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        self.resetCell()
    }
    
    public func setViewModel(_ viewModel: AccountSelectionViewModelProtocol, accessibilityIdendtifier: String) {
        self.availableAmountTitleLabel.text = localized("transaction_label_availableBalance")
        self.accountTitleLabel.text = viewModel.alias
        self.accountNumberLabel.text = viewModel.iban
        self.availableAmountLabel.attributedText = viewModel.currentBalanceAmount
        self.setAccessibilityIdentifiers(accessibilityIdendtifier)
    }
    
    public func setHighlighted() {
        self.containerView.backgroundColor = .darkTorquoise
        self.accountTitleLabel.textColor = .white
        self.accountNumberLabel.textColor = .white
        self.availableAmountTitleLabel.textColor = .white
        self.availableAmountLabel.textColor = .white
    }
    
    public func setUnhighlighted() {
        self.containerView.backgroundColor = .white
        self.accountTitleLabel.textColor = .lisboaGray
        self.accountNumberLabel.textColor = .lisboaGray
        self.availableAmountTitleLabel.textColor = .lisboaGray
        self.availableAmountLabel.textColor = .lisboaGray
    }
}

private extension AccountSelectionTableViewCell {
    func setAppearance() {
        self.containerView.backgroundColor = .white
        self.accountTitleLabel.setSantanderTextFont(type: .bold, size: 18, color: .lisboaGray)
        self.accountNumberLabel.setSantanderTextFont(type: .light, size: 14, color: .lisboaGray)
        self.availableAmountTitleLabel.setSantanderTextFont(type: .regular, size: 12, color: .lisboaGray)
        self.availableAmountLabel.textColor = .lisboaGray
        self.selectionStyle = .none
    }
    
    func resetCell() {
        self.availableAmountTitleLabel.text = nil
        self.accountTitleLabel.text = nil
        self.accountNumberLabel.text = nil
        self.availableAmountLabel.attributedText = nil
    }
    
    func setAccessibilityIdentifiers(_ identifier: String) {
        self.accountTitleLabel.accessibilityIdentifier = "accountTitleLabel" + identifier
        self.accountNumberLabel.accessibilityIdentifier = "accountNumberLabel" + identifier
        self.availableAmountTitleLabel.accessibilityIdentifier = "availableAmountTitleLabel" + identifier
        self.availableAmountLabel.accessibilityIdentifier = "availableAmountLabel" + identifier
    }
}
 
