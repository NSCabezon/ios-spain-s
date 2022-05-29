//
//  WithoutTitleLisboaTextField.swift
//  UI
//
//  Created by Tania Castellano Brasero on 18/02/2020.
//

import Foundation

public class WithoutTitleLisboaTextField: LisboaTextfield {
    
    @IBOutlet weak var elementStackVeiw: UIStackView!
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if let text = self.field.text, !text.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    public func insertActionView(_ view: UIView, at index: Int) {
        self.elementStackVeiw.insertArrangedSubview(view, at: index)
    }
}
