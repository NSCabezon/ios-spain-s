//
//  BankDetailProductsConfigHeaderView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 14/7/21.
//

import UI
import CoreFoundationLib

final class BankDetailProductsConfigHeaderView: XibView {
    @IBOutlet private weak var safeImageView: UIImageView!
    @IBOutlet private weak var safeLabel: UILabel!
    @IBOutlet private weak var bankIconImageView: UIImageView!
    @IBOutlet private weak var totalProductsLabel: UILabel!
    @IBOutlet private weak var lastUpdateLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModel(_ viewModel: BankDetailProductsHeaderViewModel) {
        self.lastUpdateLabel.configureText(withLocalizedString: viewModel.lastUpdateText)
        self.bankIconImageView.loadImage(urlString: viewModel.bankImageUrl)
        self.totalProductsLabel.configureText(withLocalizedString: viewModel.totalProductsText)
    }
}

private extension BankDetailProductsConfigHeaderView {
    func setupView() {
        self.setSafeStackView()
        self.setLabelsStyle()
        self.setAccesibilityIdentifiers()
    }
    
    func setSafeStackView() {
        self.safeLabel.font = .santander(family: .micro, type: .regular, size: 12)
        self.safeLabel.textColor = .brownishGray
        self.safeLabel.configureText(withKey: "analysis_label_safeEnvironment")
        self.safeImageView.image = Assets.image(named: "icnSecurePurchase")
    }
    
    func setLabelsStyle() {
        self.totalProductsLabel.font = .santander(family: .micro, type: .regular, size: 14)
        self.totalProductsLabel.textColor = .brownishGray
        self.lastUpdateLabel.font = .santander(family: .text, type: .regular, size: 12)
        self.lastUpdateLabel.textColor = .grafite
    }
    
    func setAccesibilityIdentifiers() {
        self.lastUpdateLabel.accessibilityIdentifier = AccessibilityExpensesAnalysisBankConfigDetail.lastConnectionLabel
        self.bankIconImageView.accessibilityIdentifier = AccessibilityExpensesAnalysisBankConfigDetail.bankHeaderImage
        self.totalProductsLabel.accessibilityIdentifier = AccessibilityExpensesAnalysisBankConfigDetail.numberOfProductsLabel
        self.safeImageView.accessibilityIdentifier = AccessibilityExpensesAnalysisBankConfigDetail.lastConnectionLabel
        self.safeLabel.accessibilityIdentifier = AccessibilityExpensesAnalysisBankConfigDetail.safeLabel
    }
}
