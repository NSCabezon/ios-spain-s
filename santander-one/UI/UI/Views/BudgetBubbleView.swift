//
//  BudgetBubbleView.swift
//  UI
//
//  Created by David Gálvez Alonso on 11/03/2020.
//

import UIKit
import CoreFoundationLib

final public class BudgetBubbleView: UIDesignableView {
   
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var closeView: UIView!
    @IBOutlet weak private var closeImageView: UIImageView!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var budgetSlider: UISlider!
    @IBOutlet weak private var minimumLabel: UILabel!
    @IBOutlet weak private var maximumLabel: UILabel!
    @IBOutlet weak private var amountTextField: SmallLisboaTextField!
    
    @IBOutlet weak public var saveButton: UIButton!
    
    public weak var delegate: BudgetBubbleViewProtocol?
    public var closeAction: (() -> Void)?

    private var sliderRange: Int = 1
    private var minimumValue: Int = 0
    
    private var minimum = 0
    private var maximum = 0

    public var amountText: String? {
        let text = amountTextField.field?.text ?? ""
        let placeholder = amountTextField.field?.placeholder ?? ""
        return text.isEmpty ? (placeholder.isEmpty ? nil : placeholder) : text
    }
    
    public var amountDecimal: Decimal? {
        return self.amountFormmater.formatAmount(fromString: self.amountText)
    }
    
    lazy var amountFormmater: UIAmountTextFieldFormatter = {
      return UIAmountTextFieldFormatter(maximumIntegerDigits: 12, maximumFractionDigits: 0)
    }()
    
    private let withSeparator: NumberFormatter = {
        return formatterForRepresentation(.amountTextField(maximumFractionDigits: 0, maximumIntegerDigits: 12))
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func commonInit() {
        super.commonInit()
        
        self.configureView()
        self.configureLabels()
        self.configureButton()
        self.configureSlider()
        self.configureTextField()
        self.configureAccessibility()
        self.setAccessibility()
        
        self.delegate?.didShowBudget()
    }
    
    public func setBudget(_ editBudget: EditBudgetEntity) {
        let minText = (withSeparator.string(for: editBudget.minimum) ?? "")
        let maxText = (withSeparator.string(for: editBudget.maximum) ?? "")
        minimumLabel.text = minText.amountAndCurrency()
        maximumLabel.text = maxText.amountAndCurrency()
        amountTextField.updateData(text: withSeparator.string(for: editBudget.budget))
        
        let steps = (editBudget.maximum - editBudget.minimum) / editBudget.rangeValue
        
        budgetSlider.maximumValue = Float(steps)
        budgetSlider.value = Float(editBudget.budget - editBudget.minimum) / Float(editBudget.rangeValue)
        
        sliderRange = editBudget.rangeValue
        minimumValue = editBudget.minimum
        
        minimum = editBudget.minimum
        maximum = editBudget.maximum
        
        didEditTextfield()
    }
    
    @IBAction func didPressSaveButton(_ sender: Any) {
        if let amountDecimal = amountDecimal {
            delegate?.didPressSaveButton(budget: Double(truncating: amountDecimal as NSDecimalNumber) )
        }
        closeAction?()
    }

    @IBAction func didChangeValue(_ sender: UISlider, event: UIEvent) {
        let valueInt = minimumValue + Int(sender.value) * sliderRange
        amountTextField.updateData(text: withSeparator.string(for: valueInt))
        
        guard let touchEvent = event.allTouches?.first else { return }
        if touchEvent.phase == .began {
            delegate?.didChangedSlide()
        }
    }
}

// MARK: - Private methods

private extension BudgetBubbleView {
    
    func configureView() {
        self.accessibilityViewIsModal = true
        self.backgroundColor = .white
        self.closeImageView.image = Assets.image(named: "icnClose")
        self.closeView.isUserInteractionEnabled = true
        self.closeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressClose)))
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    func configureLabels() {
        titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 16)
        titleLabel.text = localized("pg_label_budget")
        titleLabel.textColor = UIColor.lisboaGray
        
        subtitleLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        subtitleLabel.text = localized("tooltip_text_totSpend")
        subtitleLabel.textColor = UIColor.grafite
        
        minimumLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        minimumLabel.textColor = UIColor.mediumSanGray
             
        maximumLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        maximumLabel.textColor = UIColor.mediumSanGray
    }
    
    func configureButton() {
        saveButton.titleLabel?.font = UIFont.santander(family: .text, type: .bold, size: 13.0)
        saveButton.setTitle(localized("budget_button_saveBudget"), for: .normal)
        saveButton.setTitleColor(UIColor.white, for: .normal)
        saveButton.layer.cornerRadius = saveButton.frame.height/2
        setSaveButton(isEnabled: true)
    }
    
    func configureSlider() {
        budgetSlider.tintColor = .darkTorquoise
        budgetSlider.setThumbImage(Assets.image(named: "icnSlectorFilter"), for: .normal)
        budgetSlider.isContinuous = true
        budgetSlider.minimumValue = 0
    }
    
    func configureTextField() {
        amountTextField.field.keyboardType = .numberPad
        let icnCurrency = NumberFormattingHandler.shared.getDefaultCurrencyTextFieldIcn()
        amountTextField.configure(with: self.amountFormmater,
                                      title: "",
                                      extraInfo: (image: Assets.image(named: icnCurrency),
                                                  action: { self.amountTextField.field.becomeFirstResponder() }))
        amountTextField.field.font = UIFont.santander(family: .text, type: .bold, size: 22.0)
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.santanderRed
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: localized("generic_button_accept"), style: UIBarButtonItem.Style.done, target: self, action: #selector(self.didPressDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        amountTextField.field.inputAccessoryView = toolBar
        amountTextField.field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    func configureAccessibility() {
        saveButton.accessibilityIdentifier = AccessibilityBudgetBubble.btnSaveBudget.rawValue
        amountTextField.accessibilityIdentifier = AccessibilityBudgetBubble.inputImportBudget.rawValue
        self.closeView.accessibilityLabel = localized("siri_voiceover_close")
    }
    
    func setAccessibility() {
        self.closeView.isAccessibilityElement = true
    }
    
    @objc func didPressClose() {
        closeAction?()
    }
    
    @objc func didPressDone() {
        amountTextField.updateData(text: amountText ?? "0")
        endEditing(true)
        didEditTextfield()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        didEditTextfield()
    }
    
    func didEditTextfield() {
        if let amountDecimal = amountDecimal {
            let amountInt = Int(truncating: amountDecimal as NSDecimalNumber)
            setSaveButton(isEnabled: amountInt >= minimum && amountInt <= maximum)
            budgetSlider.value = Float((amountInt - minimumValue) / sliderRange)
            if amountInt > maximum, maximum != 0 {
                var stringValue = String(amountInt)
                stringValue = String(stringValue.prefix(stringValue.count - 1))
                amountTextField.updateData(text: withSeparator.string(for: Int(stringValue) ?? 0))
            }
        }
    }
    
    func setSaveButton(isEnabled: Bool) {
        saveButton.isEnabled = isEnabled
        saveButton.backgroundColor = isEnabled ? .darkTorquoise : .lisboaGray
    }
    
    @objc func hideKeyboard() {
        self.endEditing(true)
    }
}
