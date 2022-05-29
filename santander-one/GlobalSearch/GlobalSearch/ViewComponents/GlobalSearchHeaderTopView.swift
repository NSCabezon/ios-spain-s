//
//  GlobalSearchHeaderTopView.swift
//  GlobalSearch
//
//  Created by César González Palomino on 24/02/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class GlobalSearchHeaderTopView: XibView {
    var textFieldAction: ((_ text: String) -> Void)?
    var clearIconAction: (() -> Void)?
    @IBOutlet weak var textField: WithoutTitleLisboaTextField!
    
    private var textfiledStyle: LisboaTextFieldStyle {
        var lisboaTextFieldStyle = LisboaTextFieldStyle.default
        lisboaTextFieldStyle.fieldFont = UIFont.santander(family: .text, type: .regular, size: 16)
        lisboaTextFieldStyle.fieldTextColor = .lisboaGray
        lisboaTextFieldStyle.containerViewBorderColor = UIColor.lightSky.cgColor
        lisboaTextFieldStyle.verticalSeparatorBackgroundColor = UIColor.darkTorquoise
        lisboaTextFieldStyle.extraInfoHorizontalSeparatorBackgroundColor = UIColor.lightSky
        lisboaTextFieldStyle.extraInfoViewBackgroundColor = .white
        lisboaTextFieldStyle.fieldBackgroundColor = .white
        lisboaTextFieldStyle.containerViewBackgroundColor = .white
        lisboaTextFieldStyle.visibleTitleLabelFont = UIFont.systemFont(ofSize: 0)
        
        return lisboaTextFieldStyle
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        textField.setCustomStyle(textfiledStyle)
        textField.configure(with: nil,
                            title: localized("globalSearch_inputText_whatNeed"),
                            style: textfiledStyle,
                            extraInfo: (Assets.image(named: "icnSearch"), action: nil),
                            disabledActions: TextFieldActions.usuallyDisabledActions)
        textField.field.addTarget(self, action: #selector(textFieldDidChange),
                                  for: UIControl.Event.editingChanged)
        textField.field.autocapitalizationType = .none
        textField.field.returnKeyType = .done
        textField.setAllowOnlyCharacters(.search)
        textField.field.autocorrectionType = .no
        textField.field.accessibilityIdentifier = "areaInputTexts"
    }
    
    @objc private func textFieldDidChange(sender: UITextField) {
        guard let text = sender.text else { return }
        if text.isEmpty {
            textField.configure(extraInfo: (Assets.image(named: "icnSearch"), action: nil))
        } else {
            textField.configure(extraInfo: (Assets.image(named: "clearField"),
                                            action: {
                                                self.textField.updateData(text: "")
                                                self.textField.configure(extraInfo: (Assets.image(named: "icnSearch"), action: nil))
                                                self.clearIconAction?()
            }))
        }
        textFieldAction?(text)
    }
}
