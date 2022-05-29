//
//  GeneralBudgetViewController.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 01/04/2020.
//

import UI
import CoreFoundationLib

protocol GeneralBudgetViewProtocol: UIViewController {
    var presenter: GeneralBudgetPresenterProtocol? { get }
    
    func setBudget(_ editBudget: EditBudgetEntity)
    func loadingIsHidden(_ isHidden: Bool)
}

class GeneralBudgetViewController: UIViewController {
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var budgetSlider: UISlider!
    @IBOutlet weak private var minimumLabel: UILabel!
    @IBOutlet weak private var maximumLabel: UILabel!
    @IBOutlet weak private var amountTextField: SmallLisboaTextField!
    @IBOutlet weak private var saveButton: UIButton!
    @IBOutlet weak private var separatorView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingImageView: UIImageView!
    
    let presenter: GeneralBudgetPresenterProtocol?
    
    private var sliderRange: Int = 1
    private var minimumValue: Int = 0
    
    private var minimum = 0
    private var maximum = 0
    
    public var amountText: String? {
        return amountTextField.text?.isEmpty ?? true ? nil : amountTextField.text
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
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, presenter: GeneralBudgetPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
        
        self.presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
        self.loadingImageView.restartIfNecessary()
    }
    
    @objc func didPressSaveButton() {
        if let amountDecimal = amountDecimal {
            presenter?.didPressSaveButton(budget: Double(truncating: amountDecimal as NSDecimalNumber))
        }
    }
    
    @IBAction func didChangeValue(_ sender: UISlider, event: UIEvent) {
        let valueInt = self.minimumValue + Int(sender.value) * self.sliderRange
        self.amountTextField.updateData(text: withSeparator.string(for: valueInt))
        
        guard let touchEvent = event.allTouches?.first else { return }
        if touchEvent.phase == .began {
            self.presenter?.sliderTouchCancel()
        }
    }
    
    @IBAction private func sliderTouchCancel(_ sender: UISlider) {
        self.presenter?.sliderTouchCancel()
    }
}

// MARK: - Private methods

private extension GeneralBudgetViewController {
    
    func commonInit() {
        self.configureView()
        self.configureLabels()
        self.configureButton()
        self.configureSlider()
        self.configureTextField()
        self.configureAccessibility()
    }
    
    func configureNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .white, 
            title: .title(key: "pgCustomize_label_generalBudget")
        )
        builder.setLeftAction(.back(action: #selector(backDidPressed)))
        builder.setRightActions(.close(action: #selector(closeDidPressed)))
        builder.build(on: self, with: nil)
    }
    
    func configureView() {
        self.view.applyGradientBackground(colorStart: .white, colorFinish: .skyGray)
        self.separatorView.backgroundColor = .mediumSkyGray
        self.loadingImageView.setPointsLoader()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard)))
    }
    
    func configureLabels() {
        self.titleLabel.font = UIFont.santander(family: .text, type: .light, size: 16)
        self.titleLabel.text = localized("generalBudget_label_totSpend")
        self.titleLabel.textColor = UIColor.grafite
        self.minimumLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        self.minimumLabel.textColor = UIColor.mediumSanGray
        self.maximumLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        self.maximumLabel.textColor = UIColor.mediumSanGray
    }
    
    func configureButton() {
        self.saveButton.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 16.0)
        self.saveButton.setTitle(localized("generic_button_save"), for: .normal)
        self.saveButton.setTitleColor(UIColor.santanderRed, for: .normal)
        self.saveButton.layer.cornerRadius = saveButton.frame.height/2
        self.saveButton.backgroundColor = .white
        self.saveButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didPressSaveButton)))
        self.setSaveButton(isEnabled: true)
    }
    
    func configureSlider() {
        self.budgetSlider.tintColor = .darkTorquoise
        self.budgetSlider.setThumbImage(Assets.image(named: "icnSlectorFilter"), for: .normal)
        self.budgetSlider.isContinuous = true
        self.budgetSlider.minimumValue = 0
    }
    
    func configureTextField() {
        self.amountTextField.field.keyboardType = .numberPad
        let icnCurrency = NumberFormattingHandler.shared.getDefaultCurrencyTextFieldIcn()
        self.amountTextField.configure(with: self.amountFormmater,
                                  title: "",
                                  extraInfo: (image: Assets.image(named: icnCurrency),
                                              action: { self.amountTextField.field.becomeFirstResponder() }))
        self.amountTextField.field.font = UIFont.santander(family: .text, type: .bold, size: 22.0)
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.santanderRed
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: localized("generic_button_accept"), style: UIBarButtonItem.Style.done, target: self, action: #selector(self.didPressDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.amountTextField.field.inputAccessoryView = toolBar
        self.amountTextField.field.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    func configureAccessibility() {
        self.saveButton.accessibilityIdentifier = AccessibilityPersonalArea.btnSave
        self.amountTextField.accessibilityIdentifier = AccessibilityPersonalArea.inputImportBudget
        self.budgetSlider.accessibilityIdentifier = AccessibilityPersonalArea.budgetSlider
        self.maximumLabel.accessibilityIdentifier = AccessibilityPersonalArea.maximumLabel
        self.titleLabel.accessibilityIdentifier = AccessibilityPersonalArea.titleLabel
        self.minimumLabel.accessibilityIdentifier = AccessibilityPersonalArea.minimumLabel
    }
    
    @objc private func backDidPressed() { self.presenter?.backDidPressed() }
    @objc private func closeDidPressed() { self.presenter?.closeDidPressed() }
    
    @objc func didPressDone() {
        self.amountTextField.updateData(text: self.amountText ?? "0")
        view.endEditing(true)
        self.didEditTextfield()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.didEditTextfield()
    }
    
    func didEditTextfield() {
        if let amountDecimal = self.amountDecimal {
            let amountInt = Int(truncating: amountDecimal as NSDecimalNumber)
            self.setSaveButton(isEnabled: amountInt >= self.minimum && amountInt <= self.maximum)
            self.budgetSlider.value = Float((amountInt - self.minimumValue) / self.sliderRange)
            if amountInt > self.maximum, self.maximum != 0 {
                var stringValue = String(amountInt)
                stringValue = String(stringValue.prefix(stringValue.count - 1))
                self.amountTextField.updateData(text: withSeparator.string(for: Int(stringValue) ?? 0))
            }
        }
    }
    
    func setSaveButton(isEnabled: Bool) {
        self.saveButton.isEnabled = isEnabled
        self.saveButton.layer.borderColor = isEnabled ? UIColor.santanderRed.cgColor : self.saveButton.titleColor(for: .disabled)?.cgColor
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

extension GeneralBudgetViewController: GeneralBudgetViewProtocol {
    
    func setBudget(_ editBudget: EditBudgetEntity) {
        let minText = (withSeparator.string(for: editBudget.minimum) ?? "")
        let maxText = (withSeparator.string(for: editBudget.maximum) ?? "")
        self.minimumLabel.text = minText.amountAndCurrency()
        self.maximumLabel.text = maxText.amountAndCurrency()
        self.amountTextField.updateData(text: withSeparator.string(for: editBudget.budget))
        let steps = (editBudget.maximum - editBudget.minimum) / editBudget.rangeValue
        self.budgetSlider.maximumValue = Float(steps)
        self.budgetSlider.value = Float(editBudget.budget - editBudget.minimum) / Float(editBudget.rangeValue)
        self.sliderRange = editBudget.rangeValue
        self.minimumValue = editBudget.minimum
        self.minimum = editBudget.minimum
        self.maximum = editBudget.maximum
        self.didEditTextfield()
    }
    
    func loadingIsHidden(_ isHidden: Bool) {
        self.loadingView.isHidden = isHidden
        isHidden ? self.loadingImageView.removeLoader() : self.loadingImageView.setPointsLoader()
    }
}
