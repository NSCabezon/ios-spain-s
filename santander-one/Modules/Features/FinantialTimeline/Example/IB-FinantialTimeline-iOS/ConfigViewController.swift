//
//  ConfigViewController.swift
//  IB-FinantialTimeline-iOS
//
//  Created by Hernán Villamil on 09/09/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SantanderUIKitLib

protocol ConfigControllerDelegate {
    func onTechChange(_ isNative: Bool)
    func onHostDidChange(_ host: String)
    func onLanguageDidChange(_ language: String)
    func onMaskCharChanged(_ mask: String)
    func onmaxDisplayNumberCharChanged(_ maxChar: Int)
    func onResetStorageDidChange(_ reset: Bool)
    func showWidgetDidChange(_ isOn: Bool)
    func daysDidChange(_ days: Int)
    func elementsDidChange(_ elements: Int)
}

class ConfigViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var techLabel: UILabel!
    @IBOutlet weak var techSwitch: UISwitch!
    @IBOutlet weak var widgetLabel: UILabel!
    @IBOutlet weak var widgetSwitch: UISwitch!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var daysTF: UITextField!
    @IBOutlet weak var elementLabel: UILabel!
    @IBOutlet weak var elementsTF: UITextField!
    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var hostlabel: UILabel!
    @IBOutlet weak var maskLabel: UILabel!
    @IBOutlet weak var maskTF: UITextField!
    @IBOutlet weak var maxMaskLabel: UILabel!
    @IBOutlet weak var maxMaskLabelTF: UITextField!
    @IBOutlet weak var resetStorageSwitch: UISwitch!
    @IBOutlet weak var resetStorageLabel: UILabel!
    
    let dropdown = SantanderDropDown<LanguageSelector>()
    
    var host: String? = TimeLineURL.angularURL?.absoluteString
    var isNative: Bool = true
    var language: String = "en"
    var maxDisplayNumberChar: Int = 4
    var maskChar: String = "***"
    var delegate: ConfigControllerDelegate?
    var resetStorage: Bool = false
    var showWidgetState = false

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        prepareUI()
    }

    func prepareUI() {
        prepareLabels()
        prepareTextField()
        prepareSwitchTech()
        prepareResetStorageSwitch()
        prepareDropDown()
        prepareWidgetSwitch()
    }
    
    func prepareSwitchTech() {
        techSwitch.isOn = isNative
        techSwitch.onTintColor = UIColor.primary
    }
    
    func prepareWidgetSwitch() {
        widgetSwitch.isOn = showWidgetState
        widgetSwitch.onTintColor = UIColor.primary
    }
    
    func prepareResetStorageSwitch() {
        resetStorageSwitch.isOn = resetStorage
        resetStorageSwitch.onTintColor = UIColor.primary
    }
    
    func prepareLabels() {
        prepare(label: techLabel, with: NSLocalizedString("native.tech", comment: ""))
        prepare(label: hostlabel, with: NSLocalizedString("native.angular.host", comment: ""))
        prepare(label: maskLabel, with: NSLocalizedString("native.angular.mask", comment: ""))
        prepare(label: maxMaskLabel, with: NSLocalizedString("native.angular.max.char", comment: ""))
        prepare(label: resetStorageLabel, with: NSLocalizedString("native.reset.storage", comment: ""))
        prepare(label: daysLabel, with: NSLocalizedString("native.max.days", comment: ""))
        prepare(label: elementLabel, with: NSLocalizedString("native.max.elemets", comment: ""))
        prepare(label: widgetLabel, with: NSLocalizedString("native.widget.mode", comment: ""))
    }
    
    func prepare(label: UILabel, with text: String) {
        label.textColor = UIColor.greyishBrown
        label.text = text
    }
    
    func prepareTextField() {
        prepareHostTF()
        prepareMaskTF()
        prepareMaxMaskTF()
        prepareDaysTF()
        prepareElementsTF()
    }
    
    func prepareDaysTF() {
        daysTF.text = "7"
        daysTF.addTarget(self, action:  #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        daysTF.delegate = self
        daysTF.enablesReturnKeyAutomatically = true
    }
    
    func prepareElementsTF() {
        elementsTF.text = "3"
        elementsTF.addTarget(self, action:  #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        elementsTF.delegate = self
        elementsTF.enablesReturnKeyAutomatically = true
    }
    
    func prepareHostTF() {
        hostTextField.text = host
        hostTextField.addTarget(self, action:  #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        hostTextField.delegate = self
        hostTextField.enablesReturnKeyAutomatically = true
    }
    
    func prepareMaskTF() {
        maskTF.text = maskChar
        maskTF.addTarget(self, action:  #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        maskTF.delegate = self
        maskTF.enablesReturnKeyAutomatically = true
    }
    
    func prepareMaxMaskTF() {
        maxMaskLabelTF.text = "\(maxDisplayNumberChar)"
        maxMaskLabelTF.addTarget(self, action:  #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        maxMaskLabelTF.delegate = self
        maxMaskLabelTF.enablesReturnKeyAutomatically = true
    }
    
    func prepareDropDown() {
        dropdown.dropDownDelegate = self
        dropdown.items = getLangauages()
        dropdown.color = .turquoise
        dropdown.theme = .white
        dropdown.hintMessage = "Select a language"
        stackView.insertArrangedSubview(dropdown, at: 0)
        NSLayoutConstraint.activate([
            dropdown.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 16),
            dropdown.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -16)
            ])
    }
    
    @IBAction func onTechChange(_ sender: UISwitch) {
        self.isNative = sender.isOn
        delegate?.onTechChange(sender.isOn)
    }
    
    @IBAction func onResetStorageChange(_ sender: UISwitch) {
        self.resetStorage = sender.isOn
        delegate?.onResetStorageDidChange(sender.isOn)
    }
    
    @IBAction func widgetAction(_ sender: UISwitch) {
        delegate?.showWidgetDidChange(sender.isOn)
    }
    
}

// MARK: - UITextField
extension ConfigViewController: UITextFieldDelegate {
    @objc func  textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        switch textField {
        case hostTextField:
            self.host = text
            delegate?.onHostDidChange(text)
        case maskTF:
            self.maskChar = text
            delegate?.onMaskCharChanged(text)
        case maxMaskLabelTF:
            guard let max = Int(text) else { return }
            self.maxDisplayNumberChar = max
            delegate?.onmaxDisplayNumberCharChanged(max)
        case daysTF:
            guard let days = Int(text) else { return }
            delegate?.daysDidChange(days)
        case elementsTF:
            guard let elements = Int(text) else { return }
            delegate?.elementsDidChange(elements)
        default:
            break
        }
    }
}

// MARK: - SantanderDropDownDelegate
extension ConfigViewController: SantanderDropDownDelegate {
    func dropDownSelected<T>(_ item: SantanderDropDownData<T>, _ sender: SantanderDropDown<T>) {
        guard let itemSelected = item.value as? LanguageSelector else { return }
        self.language = itemSelected.code
        delegate?.onLanguageDidChange(itemSelected.code)
    }
    
    func getLangauages() -> [SantanderDropDownData<LanguageSelector>] {
        let spanish =  NSLocalizedString("languages.spanish", comment: "")
        let english =  NSLocalizedString("languages.english", comment: "")
        
        let item1 = SantanderDropDownData(label: spanish, value: LanguageSelector(name: spanish, code: "es", id: 0))
        let item2 = SantanderDropDownData(label: english, value: LanguageSelector(name: english, code: "en", id: 1))
        
        return [item1, item2]
    }
}

struct LanguageSelector {
    var name: String
    var code: String
    var id: Int
}
