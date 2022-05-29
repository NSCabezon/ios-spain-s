//
//  ExportEventViewController+Delegate.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 25/09/2019.
//

import Foundation

// MARK: - GlobileGlobileRadioButtonGroupDelegate
extension ExportEventViewController: GlobileRadioButtonGroupDelegate {
    func getOptions() -> GlobileRadioButtonGroup {
        let option1 = getButton(with: ExportEventString().allTimeOption)
        let option2 = getButton(with: ExportEventString().thisMonthoOtion)
        let option4 = getButton(with: ExportEventString().withSpecificTypeOption)
        
        let buttons = [option1, option2, option4]
        let group = GlobileRadioButtonGroup(radioButtons: buttons)
        group.delegate = self
        
        return group
    }
    
    func getButton(with title: String) -> GlobileRadioButton {
        let button = GlobileRadioButton()
        button.text = title
        button.radioButtonColor = .turquoise
        return button
    }
    
    func didSelect(radioButton: GlobileRadioButton) {
        self.selectedButton = radioButton.text
        self.setExportEventsButton()
    }
}

extension ExportEventViewController: GlobileCheckboxGroupDelegate {
    func getTypeList() -> GlobileCheckBoxGroup {
        var list = [GlobileCheckBox]()
        typeListArray.forEach({list.append(getCheckBox(with: $0))})
        let group = GlobileCheckBoxGroup(checkboxes: list)
        group.delegate = self
        return group
    }
    
    func getCheckBox(with text: String) -> GlobileCheckBox {
        let check = GlobileCheckBox()
        check.text = text
        check.color = .turquoise
        check.isSelected = true
        return check
    }
    
    func didSelect(checkbox: GlobileCheckBox) {
        guard let text = checkbox.text else { return }
        typeListArray.append(text)
        setExportEventsButton()
    }
    
    func didDeselect(checkbox: GlobileCheckBox) {
        guard let text = checkbox.text else { return }
        typeListArray.removeAll(where: {$0 == text})
        setExportEventsButton()
    }
}
