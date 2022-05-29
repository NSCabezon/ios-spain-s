//
//  AmountRangeFilterView.swift
//  UI
//
//  Created by Laura González on 12/02/2020.
//

import Foundation
import CoreFoundationLib
import OpenCombine

public protocol AmountRangeFilterViewDelegate: AnyObject {
    func didOpenSection(view: UIView)
}

public class AmountRangeFilterView: UIDesignableView {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var fromAmountTextField: LisboaTextfield!
    @IBOutlet weak var toAmountTextField: LisboaTextfield!
    @IBOutlet weak var arrowImage: UIImageView!
    
    public weak var delegate: AmountRangeFilterViewDelegate?
    public var onDidOpenSectionSubject = PassthroughSubject<UIView, Never>()
    
    public var fromAmount: String? {
        guard let emptyText = fromAmountTextField.text?.isEmpty, let optionalText = fromAmountTextField.text else {
            return nil
        }
        return emptyText ? nil : optionalText
    }
    
    public var toAmount: String? {
        guard let emptyText = toAmountTextField.text?.isEmpty, let optionalText = toAmountTextField.text else {
            return nil
        }
        return emptyText ? nil : optionalText
    }
    
    public var fromDecimal: Decimal? {
        return self.fromAmountFormatter.formatAmount(fromString: self.fromAmount)
    }
    
    public var toDecimal: Decimal? {
        return self.toAmountFormatter.formatAmount(fromString: self.toAmount)
    }
    
    private var isCollapsed: Bool = true
    lazy var fromAmountFormatter: UIAmountTextFieldFormatter = {
        return UIAmountTextFieldFormatter(maximumIntegerDigits: 6, maximumFractionDigits: 2)
    }()
    lazy var toAmountFormatter: UIAmountTextFieldFormatter = {
        return UIAmountTextFieldFormatter(maximumIntegerDigits: 6, maximumFractionDigits: 2)
    }()
    
    override public func commonInit() {
        super.commonInit()
        setAppearance()
        setTextFieldAppearance()
        self.setAccessibilityIdentifiers()
        footerView.isHidden = true
        footerView.alpha = 0
    }
    
    private func setAppearance() {
        headerView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(collapseView)))
        arrowImage.image =  Assets.image(named: "icnArrowDown")
        titleView.textColor = UIColor.lisboaGray
        titleView.font = UIFont.santander(family: .text, type: .bold, size: 16)
        titleView.text = localized("search_label_value")
    }
    
    private func setTextFieldAppearance() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: localized("generic_button_accept"), style: UIBarButtonItem.Style.done, target: self, action: #selector(self.closeKeyboard))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        fromAmountTextField.field.inputAccessoryView = toolBar
        toAmountTextField.field.inputAccessoryView = toolBar
        
        fromAmountTextField.field.keyboardType = .decimalPad
        toAmountTextField.field.keyboardType = .decimalPad
        fromAmountTextField.translatesAutoresizingMaskIntoConstraints = false
        toAmountTextField.translatesAutoresizingMaskIntoConstraints = false
        let icnCurrency = NumberFormattingHandler.shared.getDefaultCurrencyTextFieldIcn()
        fromAmountTextField.configure(with: self.fromAmountFormatter,
                                      title: localized("search_label_since"),
                                      extraInfo: (image: Assets.image(named: icnCurrency),
                                                  action: { self.fromAmountTextField.field.becomeFirstResponder() }))
        toAmountTextField.configure(with: self.toAmountFormatter,
                                    title: localized("search_label_until"),
                                    extraInfo: (image: Assets.image(named: icnCurrency),
                                                action: { self.toAmountTextField.field.becomeFirstResponder() }))
    }
    
    public func set(fromAmount: String, toAmount: String, isColapsed: Bool) {
        fromAmountTextField.updateData(text: fromAmount)
        toAmountTextField.updateData(text: toAmount)        
        isCollapsed = isColapsed
        collapseView()
    }
    
    public func setAccessibilityIdentifiers() {
        self.titleView.accessibilityIdentifier = AccessibilityAccountFilter.amountTitleView
        self.fromAmountTextField.accessibilityIdentifier = AccessibilityAccountFilter.fromAmountTextField
        self.toAmountTextField.accessibilityIdentifier = AccessibilityAccountFilter.toAmountTextField
        self.fromAmountTextField.setAccessibleIdentifiers(titleLabelIdentifier: AccessibilityAccountFilter.titleFromAmountTextField, fieldIdentifier: AccessibilityAccountFilter.amountFromAmountTextField, imageIdentifier: AccessibilityAccountFilter.icnFromAmountTextField)
        self.toAmountTextField.setAccessibleIdentifiers(titleLabelIdentifier: AccessibilityAccountFilter.titleToAmountTextField, fieldIdentifier: AccessibilityAccountFilter.amountToAmountTextField, imageIdentifier: AccessibilityAccountFilter.icnToAmountTextField)
    }
    // MARK: - SECTION COLLAPSE
    
    @objc private func collapseView() {
        if isCollapsed {
            openSection()
        } else {
            closeSection()
        }
    }
    
    private func openSection() {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
            self.footerView.isHidden = false
            self.footerView.alpha = 1
        }, completion: { _ in
            self.delegate?.didOpenSection(view: self)
            self.onDidOpenSectionSubject.send(self)
        })
        isCollapsed = false
        arrowImage.image =  Assets.image(named: "icnArrowUp")
        arrowImage.accessibilityIdentifier = AccessibilityAccountFilter.arrowUpSectionAmount

    }
    
    private func closeSection() {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.footerView.isHidden = true
                self.footerView.alpha = 0
        }, completion: nil)
        arrowImage.image =  Assets.image(named: "icnArrowDown")
        arrowImage.accessibilityIdentifier = AccessibilityAccountFilter.arrowDownSectionAmount
        isCollapsed = true
    }
    
    @objc func closeKeyboard() {
        fromAmountTextField.updateData(text: fromAmountTextField.field.text)
        toAmountTextField.updateData(text: toAmountTextField.field.text)
        self.endEditing(true)
    }
}
