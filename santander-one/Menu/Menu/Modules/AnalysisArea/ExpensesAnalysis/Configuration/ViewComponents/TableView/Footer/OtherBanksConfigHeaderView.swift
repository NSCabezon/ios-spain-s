//
//  OtherBanksConfigHeaderView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 6/7/21.
//

import UI
import CoreFoundationLib

final class OtherBanksConfigHeaderView: XibView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension OtherBanksConfigHeaderView {
    func setupView() {
        self.setTitleLabel()
        self.setAccessibilityIdentifiers()
        self.separatorView.backgroundColor = .lightSkyBlue
    }
    
    func setTitleLabel() {
        self.titleLabel.text = localized("analysis_label_myOtherBanks")
        self.titleLabel.setSantanderTextFont(type: .bold, size: 16, color: .lisboaGray)
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.footerOtherBanksLabel
    }
}
