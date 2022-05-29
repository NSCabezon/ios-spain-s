//
//  FinanceableAccountsSelectorView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 24/08/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class FinanceableAccountSelectorView: UIView {
    private let dropdownView: DropdownView<AccountFinanceableViewModel> = DropdownView<AccountFinanceableViewModel>(frame: .zero)
    private var onSelected: ((AccountFinanceableViewModel) -> Void)?
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func configureWithAccounts(_ accounts: [AccountFinanceableViewModel], onSelected: @escaping (AccountFinanceableViewModel) -> Void) {
        let dropdownConfiguration = DropdownConfiguration<AccountFinanceableViewModel>(title: localized("financing_hint_chooseAccount"), elements: accounts, displayMode: .growToScreenBounds(inset: 20))
        self.dropdownView.configure(dropdownConfiguration)
        self.onSelected = onSelected
    }
    
    public func selectElement(_ element: AccountFinanceableViewModel) {
        self.dropdownView.selectElement(element)
    }
}

private extension FinanceableAccountSelectorView {
    
    func setup() {
        self.accessibilityIdentifier = AccessibilityFinancingFractionalPurchases.selector
        self.addSubview(self.horizontalStackView)
        self.horizontalStackView.addArrangedSubview(self.horizontalLine(color: .mediumSkyGray))
        self.horizontalStackView.addArrangedSubview(self.verticalStackView)
        self.horizontalStackView.addArrangedSubview(self.horizontalLine(color: .mediumSkyGray))
        self.verticalStackView.addArrangedSubview(self.verticalLine(color: .mediumSkyGray))
        self.verticalStackView.addArrangedSubview(self.dropdownView)
        self.verticalStackView.addArrangedSubview(self.verticalLine(color: .darkTurqLight))
        self.dropdownView.delegate = self
        self.horizontalStackView.fullFit(topMargin: 0, bottomMargin: 6, leftMargin: 16, rightMargin: 16)
    }
    
    func verticalLine(color: UIColor) -> UIView {
        let lineContainer = UIView()
        lineContainer.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineContainer.backgroundColor = color
        return lineContainer
    }
    
    func horizontalLine(color: UIColor) -> UIView {
        let line = UIView()
        line.widthAnchor.constraint(equalToConstant: 1).isActive = true
        line.backgroundColor = color
        return line
    }
}

extension FinanceableAccountSelectorView: DropdownDelegate {
    
    func didSelectOption(element: DropdownElement) {
        guard let account = element as? AccountFinanceableViewModel else { return }
        self.onSelected?(account)
    }
}
