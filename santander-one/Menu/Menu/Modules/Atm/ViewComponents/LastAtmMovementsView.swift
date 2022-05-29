//
//  LastAtmMovementsView.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 07/09/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol LastAtmMovementsViewDelegate: AnyObject {
    func formatDate(_ date: Date) -> LocalizedStylableText
}

final class LastAtmMovementsView: XibView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lastWithdrawalsStackView: UIStackView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    public weak var delegate: LastAtmMovementsViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setViewModels(_ sortedDictionary: [(Date, [AtmMovementViewModel])]) {
        for (key, value) in sortedDictionary {
            let dateView = AtmDateSectionView(frame: .zero)
            dateView.configure(withDate: delegate?.formatDate(key) ?? LocalizedStylableText(text: "", styles: nil))
            self.lastWithdrawalsStackView.addArrangedSubview(dateView)
            for (index, viewModel) in value.enumerated() {
                let lastWithdrawalAtmView = AtmMovementView(frame: .zero)
                lastWithdrawalAtmView.setup(movement: viewModel.movementDescription, account: viewModel.accountNumber, amount: viewModel.amount ?? NSAttributedString())
                if index + 1 == value.count {
                    lastWithdrawalAtmView.dottedHidden(isLast: true)
                } else {
                    lastWithdrawalAtmView.dottedHidden(isLast: false)
                }
                self.lastWithdrawalsStackView.addArrangedSubview(lastWithdrawalAtmView)
            }
        }
        self.addAccessibilityIdentifiers()
    }
}

private extension LastAtmMovementsView {
    
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.backgroundColor = .skyGray
        self.titleLabel?.font = .santander(family: .text, type: .bold, size: 18)
        self.titleLabel?.textColor = .lisboaGray
        self.titleLabel?.configureText(withKey: localized("atm_tilte_lastOperations"))
        self.containerView?.drawRoundedAndShadowedNew(radius: 6, borderColor: .mediumSkyGray, widthOffSet: 1, heightOffSet: 2)
    }
    
    func addAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityAtm.AtmListOperations.title
        self.containerView.accessibilityIdentifier = AccessibilityAtm.AtmListOperations.listOperation
        self.lastWithdrawalsStackView.arrangedSubviews.forEach({
            $0.accessibilityIdentifier = AccessibilityAtm.AtmListOperations.atmElementOpeartion
        })
    }
}
