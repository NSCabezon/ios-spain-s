//
//  CustomizableComponents.swift
//  UI
//
//  Created by Carlos Monfort Gómez on 22/06/2020.
//

import Foundation

extension LisboaTextField {
    
    public enum TextFieldType {
        case floatingTitle
        case simple
    }
    
    public struct CustomizableComponents {
        public let textField: UITextField
        public let floatingLabel: UILabel?
        
        init(textField: UITextField, floatingLabel: UILabel? = nil) {
            self.textField = textField
            self.floatingLabel = floatingLabel
        }
    }
    
    public struct WritableTextField {
        let type: TextFieldType
        let formatter: TextFieldFormatter?
        let disabledActions: [TextFieldActions]
        let keyboardReturnAction: (() -> Void)?
        weak var textFieldDelegate: FloatingTitleLisboaTextFieldDelegate?
        let textfieldCustomizationBlock: ((CustomizableComponents) -> Void)?
        
        public init(
            type: TextFieldType,
            formatter: TextFieldFormatter? = nil,
            disabledActions: [TextFieldActions] = [],
            keyboardReturnAction: (() -> Void)? = nil,
            textFieldDelegate: FloatingTitleLisboaTextFieldDelegate? = nil,
            textfieldCustomizationBlock: ((CustomizableComponents) -> Void)? = nil
        ) {
            self.type = type
            self.formatter = formatter
            self.disabledActions = disabledActions
            self.keyboardReturnAction = keyboardReturnAction
            self.textfieldCustomizationBlock = textfieldCustomizationBlock
            self.textFieldDelegate = textFieldDelegate
        }
    }
    
    public struct ActionableTextField {
        let type: TextFieldType
        let action: () -> Void
        
        public init(type: TextFieldType, action: @escaping () -> Void) {
            self.type = type
            self.action = action
        }
    }
    
    public enum EditingStyle {
        case writable(configuration: WritableTextField)
        case actionable(configuration: ActionableTextField)
    }
    
    public enum RightAccessory {
        case none
        case image(String, action: () -> Void)
        case uiImage(UIImage?, action: () -> Void)
        case view(UIView)
        case actionView(UIView, action: (() -> Void)?)
        case secure(String?, String?)
    }
    
    public enum ClearAccessory {
        case none
        case clearDefault
    }
    
    public enum TextScaleType {
        case percentage(percent: CGFloat)
        case minimumFontSize(size: CGFloat)
        case noMinimumSize
        case none
    }
}
