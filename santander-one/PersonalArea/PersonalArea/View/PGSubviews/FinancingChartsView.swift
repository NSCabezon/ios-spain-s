//
//  FinancingChartsView.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 27/11/2019.
//

import Foundation
import CoreFoundationLib
import UI

protocol FinancingChartsViewDelegate: AnyObject {
    func financingChartsViewDidPressed()
}

class FinancingChartsView: DesignableView {
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private var externalViews: [UIView]?
    @IBOutlet private var internalViews: [DottedLineView]?
    @IBOutlet private weak var expensesImageView: UIImageView?
    @IBOutlet private weak var switchLabel: UILabel?
    @IBOutlet private weak var financingSwitch: UISwitch?
    @IBOutlet private weak var titleExpenseLabel: UILabel?
    @IBOutlet private weak var valueExpenseLabel: UILabel?
    @IBOutlet private weak var arrowImageView: UIImageView?
    @IBOutlet private weak var navigationStackView: UIStackView!
    weak var financingChartsViewDelegate: FinancingChartsViewDelegate?

    override func internalInit() {
        super.internalInit()
        self.commonInit()
    }
    
    @IBAction private func financingSwitchChanged() {
        let expensesImageName = self.financingSwitch?.isOn ?? false ? "imgExpenses" : "imgYourExpenseDisabling"
        self.expensesImageView?.image = Assets.image(named: expensesImageName)
        self.expensesImageView?.accessibilityIdentifier = expensesImageName
    }
        
    func setDelegate(_ delegate: FinancingChartsViewDelegate?) {
        self.financingChartsViewDelegate = delegate
    }
    
    func setSwitchIsOn(_ isOn: Bool) {
        self.financingSwitch?.isOn = isOn
        self.financingSwitchChanged()
    }
    
    func setUserBudget(_ userBudget: Double?) {
        let formatter = formatterForRepresentation(.amountTextField(maximumFractionDigits: 0, maximumIntegerDigits: 6))
        let defaultValue = formatter.string(from: 1000) ?? "0"
        let valueExpense = userBudget != nil ? (formatter.string(for: userBudget) ?? "") : defaultValue
        self.valueExpenseLabel?.text = valueExpense.amountAndCurrency()
    }
    
    func getSwitchIsOn() -> Bool {
        return self.financingSwitch?.isOn ?? false
    }    
}

private extension FinancingChartsView {
    func commonInit() {
        self.configureLabels()
        self.configureViews()
        self.setSwitchIsOn(true)
        self.setAccessibilityIdentifiers()
    }
    
    func configureLabels() {
        self.setTitleLabel()
        self.setTitleExpenseLabel()
        self.setValueExpenseLabel()
        self.setSwitchLabel()
    }
    
    func setTitleLabel() {
        self.titleLabel?.textColor = .lisboaGray
        self.titleLabel?.configureText(withKey: "displayOptions_title_initialModules",
                                  andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 14),
                                                                                       alignment: .left,
                                                                                       lineHeightMultiple: 0.8))
    }
    
    func setTitleExpenseLabel() {
        self.titleExpenseLabel?.textColor = .lisboaGray
        self.titleExpenseLabel?.configureText(withKey: "pgCustomize_label_generalBudget",
                                         andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16),
                                                                                              alignment: .left))
    }
    
    func setValueExpenseLabel() {
        self.valueExpenseLabel?.textColor = .darkTorquoise
        self.valueExpenseLabel?.font = .santander(family: .text, type: .regular, size: 16)
        self.valueExpenseLabel?.textAlignment = .right
    }
    
    func setSwitchLabel() {
        self.switchLabel?.textColor = .lisboaGray
        self.switchLabel?.configureText(withKey: "pgCustomize_text_yourExpensesAndFinance",
                                   andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16),
                                                                                        alignment: .left))
    }
    
    func configureViews() {
        self.backgroundColor = .white
        self.externalViews?.forEach { $0.backgroundColor = .mediumSkyGray }
        self.internalViews?.forEach { $0.strokeColor = .mediumSkyGray }
        self.arrowImageView?.image = Assets.image(named: "icnArrowRight")
        self.arrowImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToDidPressed)))
        self.arrowImageView?.isUserInteractionEnabled = true
        self.navigationStackView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToDidPressed)))
        self.navigationStackView?.isUserInteractionEnabled = true
        self.expensesImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToDidPressed)))
        self.expensesImageView?.isUserInteractionEnabled = true
    }
    
    @objc func goToDidPressed() {
        self.financingChartsViewDelegate?.financingChartsViewDidPressed()
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.financingChartsTitle
        self.titleExpenseLabel?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.financingChartsTitleExpense
        self.valueExpenseLabel?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.financingChartsExpenseLabel
        self.switchLabel?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.financingChartsSwitchLabel
        self.arrowImageView?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.financingChartsArrowImage
        self.financingSwitch?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.financingSwitch
    }
}
