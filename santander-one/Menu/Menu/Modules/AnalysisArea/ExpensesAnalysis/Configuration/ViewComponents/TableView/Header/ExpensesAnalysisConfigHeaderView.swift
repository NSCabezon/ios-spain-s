//
//  ExpensesAnalysisConfigHeaderView.swift
//  Pods
//
//  Created by Carlos Monfort Gómez on 30/6/21.
//

import UI
import CoreFoundationLib

final class ExpensesAnalysisConfigHeaderView: XibView {
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subTitle: UILabel!
    @IBOutlet private weak var lastUpdateLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModel(_ viewModel: ExpensesAnalysysConfigHeaderViewModel) {
        self.lastUpdateLabel.configureText(withLocalizedString: viewModel.lastUpdateText)
    }
}

private extension ExpensesAnalysisConfigHeaderView {
    func setupView() {
        self.setTitleStyle()
        self.setSubTitleStyle()
        self.setLastUpdateStyle()
        self.setAccessibilityIdentifiers()
    }
    
    func setTitleStyle() {
        self.title.setSantanderTextFont(size: 18, color: .lisboaGray)
        self.title.numberOfLines = 0
        self.title.configureText(withLocalizedString: localized("analysis_label_yourProducts"))
    }
    
    func setSubTitleStyle() {
        self.subTitle.setSantanderTextFont(type: .regular, size: 15, color: .lisboaGray)
        self.subTitle.numberOfLines = 0
        self.subTitle.text = localized("analysis_label_chooseProducts")
    }
    
    func setLastUpdateStyle() {
        self.lastUpdateLabel.setSantanderTextFont(type: .regular, size: 12, color: .grafite)
    }
    
    func setAccessibilityIdentifiers() {
        self.title.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.headerTitle
        self.subTitle.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.headerSubtitle
        self.lastUpdateLabel.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.headerLastUpdate
    }
}
