//
//  OperativeFilterView.swift
//  UI
//
//  Created by Laura González on 10/02/2020.
//
import UIKit
import CoreFoundationLib
import OpenCombine

public protocol OperativeFilterViewDelegate: AnyObject {
    func didOpenSection(view: UIView)
}

public class OperativeFilterView: UIDesignableView {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var collapseButton: UIButton!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var typePicker: WithoutTitleLisboaTextField!
    
    private var isCollapsed: Bool = true
    private var options: [String] = []
    
    public weak var delegate: OperativeFilterViewDelegate?
    public var onDidOpenSectionSubject = PassthroughSubject<UIView, Never>()
    
    override public func commonInit() {
        super.commonInit()
        configureView()
        setUpPicker()
        self.setAccessibilityIdentifiers()
    }
    
    private func configureView() {
        arrowImage.image = Assets.image(named: "icnArrowDown")
        titleView.textColor = UIColor.lisboaGray
        titleView.font = UIFont.santander(family: .text, type: .bold, size: 16)        
        footerView.isHidden = true
        footerView.alpha = 0
        headerView?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                action: #selector(collapseView)))
    }
    
    // MARK: - PICKER
    
    private func setUpPicker() {
        typePicker.configure(with: nil,
                             title: "",
                             extraInfo: (image: Assets.image(named: "icnArrowDownGreen"),
                                         action: { self.typePicker.field.becomeFirstResponder() }),
                             disabledActions: TextFieldActions.usuallyDisabledActions)
        createPicker(for: typePicker)
    }
    
    public func clear() {
        options.removeAll()
    }
    
    public func configure(viewTitle: String, textfieldOptions: [String], itemSelected: Int, isColapsed: Bool) {
        titleView.text = viewTitle
        options.append(contentsOf: textfieldOptions)
        if let picker = typePicker?.field.inputView as? UIPickerView {
            picker.reloadAllComponents()
            picker.selectRow(itemSelected, inComponent: 0, animated: false)
            typePicker.updateData(text: options[itemSelected])
        }
        self.isCollapsed = isColapsed
        collapseView()
    }
    
    func createPicker(for field: LisboaTextfield) {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.showsSelectionIndicator = true
        picker.selectRow(0, inComponent: 0, animated: false)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.santanderRed
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: localized("generic_button_accept"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePicker))
        doneButton.accessibilityIdentifier = "btnDone"
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: localized("generic_button_cancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelPicker))
        cancelButton.accessibilityIdentifier = "btnCancel"
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        field.field.inputView = picker
        field.field.inputAccessoryView = toolBar
    }
    
    @objc func donePicker() {
        if let picker = typePicker?.field.inputView as? UIPickerView {
            let selected = picker.selectedRow(inComponent: 0)
            typePicker.updateData(text: options[selected])
        }
        super.contentView?.endEditing(true)
    }
    
    @objc func cancelPicker() {
        super.contentView?.endEditing(true)
    }
    
    public func getSelectedIndex() -> Int? {
        if let picker = typePicker?.field.inputView as? UIPickerView {
            return picker.selectedRow(inComponent: 0)
        }
        return nil
    }
    
    public func setAccessibilityIdentifiers() {
        self.titleView.accessibilityIdentifier = AccessibilityAccountFilter.titleOperationType
        self.typePicker.accessibilityIdentifier = AccessibilityAccountFilter.typePickerOperationType
        self.typePicker.setAccessibleIdentifiers(fieldIdentifier: TransactionOperationTypeEntity.allCases[0].identifier, imageIdentifier: AccessibilityAccountFilter.icnPickerOperationType)
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
        arrowImage.image = Assets.image(named: "icnArrowUp")
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
        arrowImage.image = Assets.image(named: "icnArrowDown")
        isCollapsed = true
    }
    
    public func setAlwaysExpanded() {
        self.headerView.isUserInteractionEnabled = false
        self.arrowImage.isHidden = true
        self.isCollapsed = false
        self.openSection()
    }
    
    public func disableTextFieldEditing() {
        self.typePicker.disableTextFieldEditing()
    }
}

extension OperativeFilterView: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.typePicker.field.accessibilityIdentifier = TransactionOperationTypeEntity.allCases[row].identifier
    }
}

extension OperativeFilterView: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
}
