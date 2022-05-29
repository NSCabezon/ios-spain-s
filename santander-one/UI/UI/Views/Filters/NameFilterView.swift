//
//  NameFilterView.swift
//  UI
//
//  Created by Laura Gonzalez Salvador on 03/02/2020.
//

import Foundation
import CoreFoundationLib

public class NameFilterView: UIDesignableView {
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var nameTextField: LisboaTextfield!
    
    public var text: String? {
        return nameTextField.text
    }
    
    override public func commonInit() {
        super.commonInit()
        setTitleAppearance()
        setAccessibility()
    }
    
    private func setTitleAppearance() {
        titleView.textColor = UIColor.lisboaGray
        titleView.font = UIFont.santander(family: .text, type: .bold, size: 16)
    }

    public func setup() {
        self.setupTitles(viewTitle: "", textfieldTitle: "")
    }
    
    public func setupTitles(viewTitle: String, textfieldTitle: String) {
        titleView.text = viewTitle
        nameTextField.configure(with: nil, title: textfieldTitle, extraInfo: (image: Assets.image(named: "icnSearch"), action: { self.nameTextField.field.becomeFirstResponder() }))
    }
    
    public func setTitle(_ title: String?) {
        self.titleView.text = title
    }
    
    public func setText(_ text: String?) {
        self.nameTextField.updateTitle(text)
    }
    
    public func setRightView(_ view: UIView) {
        self.nameTextField.setCustomeExtraInfoView(view)
    }
    
    public func addAction(_ action: @escaping () -> Void) {
        self.nameTextField.addAction(action)
    }
    
    public func addRightViewAction(_ action: (() -> Void)?) {
        self.nameTextField.addExtraAction(action)
    }
    
    public func setAllowedCharacters(_ characterSet: CharacterSet) {
        nameTextField.setAllowOnlyCharacters(characterSet)
    }
    
    public func disableTextFieldEditing() {
        self.nameTextField.disableTextFieldEditing()
    }
    
    public func setFilterSelected(_ text: String?) {
        self.nameTextField.updateData(text: text)
    }
    
    private func setAccessibility() {
        self.titleView.accessibilityIdentifier = AccessibilityAccountFilter.conceptTitleView
        self.nameTextField.accessibilityIdentifier = AccessibilityAccountFilter.conceptTextField
        self.nameTextField.setAccessibleIdentifiers(titleLabelIdentifier: AccessibilityAccountFilter.titleConceptTextField, fieldIdentifier: AccessibilityAccountFilter.fieldConceptTextField, imageIdentifier: AccessibilityAccountFilter.icnConceptTextField)
    }
}
