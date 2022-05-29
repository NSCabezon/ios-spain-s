//
//  LisboaTextFieldFactory.swift
//  UI
//
//  Created by Carlos Monfort Gómez on 19/06/2020.
//

import Foundation

public struct LisboaTextFieldFactory {
    
    let editingStyle: LisboaTextField.EditingStyle
    
    func get() -> LisboaTextFieldViewProtocol {
        switch editingStyle {
        case .writable(configuration: let configuration):
            return self.writableLisboaTextField(configuration)
        case .actionable(configuration: let configuration):
            return self.actionableLisboaTextField(configuration)
        }
    }
}

private extension LisboaTextFieldFactory {
    func writableLisboaTextField(_ configuration: LisboaTextField.WritableTextField) -> LisboaTextFieldViewProtocol {
        switch configuration.type {
        case .floatingTitle:
            return self.floatingTitleLisboaTextField(configuration)
        case .simple:
            return self.simpleTitleLisboaTextField(configuration)
        }
    }
    
    func actionableLisboaTextField(_ configuration: LisboaTextField.ActionableTextField) -> LisboaTextFieldViewProtocol {
        switch configuration.type {
        case .floatingTitle:
            let view = ActionableFloatingLisboaTextField(frame: .zero)
            view.addAction(configuration.action)
            return view
        case .simple:
            let view = ActionableLisboaTextField(frame: .zero)
            view.addAction(configuration.action)
            return view
        }
    }
    
    func floatingTitleLisboaTextField(_ configuration: LisboaTextField.WritableTextField) -> LisboaTextFieldViewProtocol {
        let view = FloatingTitleLisboaTextField(frame: .zero)
        configuration.formatter?.delegate = view
        view.lisboaTextFieldDelegate = configuration.textFieldDelegate
        view.textField.setDisabledActions(configuration.disabledActions)
        view.setReturnAction(configuration.keyboardReturnAction)
        view.setCustomizationBlock(configuration.textfieldCustomizationBlock)
        return view
    }
    
    func simpleTitleLisboaTextField(_ configuration: LisboaTextField.WritableTextField) -> LisboaTextFieldViewProtocol {
        let view = SimpleLisboaTextField(frame: .zero)
        configuration.formatter?.delegate = view
        view.textField.setDisabledActions(configuration.disabledActions)
        view.setReturnAction(configuration.keyboardReturnAction)
        view.setCustomizationBlock(configuration.textfieldCustomizationBlock)
        return view
    }
}
