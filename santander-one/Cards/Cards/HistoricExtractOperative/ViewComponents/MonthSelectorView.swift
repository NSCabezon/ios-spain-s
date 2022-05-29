//
//  MonthSelectorView.swift
//  Cards
//
//  Created by Ignacio González Miró on 18/11/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol DidTapInMonthSelectorDelegate: AnyObject {
    func didSelectMonth(_ differenceBetweenMonths: Int, dateName: String)
}

final class MonthSelectorView: UIDesignableView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var cardSelectorTextField: SmallLisboaTextField!
    @IBOutlet private weak var monthView: MonthView!
    
    private var textFieldStyle: LisboaTextFieldStyle {
        var lisboaTextFieldStyle = LisboaTextFieldStyle.default
        lisboaTextFieldStyle.fieldFont = UIFont.santander(family: .text, type: .regular, size: 16)
        lisboaTextFieldStyle.fieldTextColor = .lisboaGray
        lisboaTextFieldStyle.fieldBackgroundColor = .white
        lisboaTextFieldStyle.containerViewBorderColor = UIColor.lightSky.cgColor
        lisboaTextFieldStyle.containerViewBackgroundColor = .white
        lisboaTextFieldStyle.verticalSeparatorBackgroundColor = UIColor.darkTorquoise
        lisboaTextFieldStyle.visibleTitleLabelFont = UIFont.santander(family: .text, type: .regular, size: 12)
        lisboaTextFieldStyle.extraInfoHorizontalSeparatorBackgroundColor = UIColor.lightSky
        lisboaTextFieldStyle.extraInfoViewBackgroundColor = .white
        return lisboaTextFieldStyle
    }
    weak var delegate: DidTapInMonthSelectorDelegate?

    override func getBundleName() -> String {
        return "Cards"
    }
    
    override func commonInit() {
        super.commonInit()
        self.setAppeareance()
        self.configureView()
        self.setAccessibilityId()
    }
}

private extension MonthSelectorView {
    func setAppeareance() {
        self.cardSelectorTextField.backgroundColor = .clear
        self.cardSelectorTextField.setCustomStyle(textFieldStyle)
    }
    
    func configureView() {
        self.monthView.setLimitMinimumDate(11)
        self.monthView.isHidden = true
        self.monthView.delegate = self
        self.cardSelectorTextField.configure(with: nil,
                                             title: localized("statementHistory_hint_selectMonth"),
                                             style: textFieldStyle,
                                             extraInfo: (image: Assets.image(named: "icnArrowDownGreen"), action: {
                                                self.didTapCardSelector()
                                             }),
                                             disabledActions: TextFieldActions.usuallyDisabledActions)
        self.cardSelectorTextField.updateData(text: self.monthView.selectedMonth.uppercased())
        self.cardSelectorTextField.field.adjustsFontSizeToFitWidth = true
        self.cardSelectorTextField.field.minimumFontSize = 12
        self.cardSelectorTextField.disableTextFieldEditing()
        self.cardSelectorTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCardSelector)))
    }
    
    func setAccessibilityId() {
        self.cardSelectorTextField.accessibilityIdentifier = AccessibilityHistoricExtract.selectorTextField.rawValue
        self.cardSelectorTextField.setAccessibleIdentifiers(
            titleLabelIdentifier: AccessibilityHistoricExtract.selectorTextField.rawValue + "Title",
            fieldIdentifier: AccessibilityHistoricExtract.selectorTextField.rawValue + "Field",
            imageIdentifier: AccessibilityHistoricExtract.selectorTextField.rawValue + "Image")
        self.containerView.accessibilityIdentifier = AccessibilityHistoricExtract.selector.rawValue
    }
    
    @objc func didTapCardSelector() {
        monthView.isHidden = !monthView.isHidden
    }
}

extension MonthSelectorView: MonthViewDelegate {
    func didSelectedDates(_ startDate: Date?, endDate: Date?) {}
    
    func didSelectMonth(_ nameMonth: String, nameYear: String, differenceBetweenMonths: Int) {
        self.cardSelectorTextField.updateData(text: nameMonth.uppercased())
        delegate?.didSelectMonth(differenceBetweenMonths, dateName: "\(nameMonth) \(nameYear)")
    }
}
