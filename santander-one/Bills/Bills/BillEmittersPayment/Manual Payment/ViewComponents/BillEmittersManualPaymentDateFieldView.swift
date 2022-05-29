//
//  BIllEmittersManualPaymentDateFieldView.swift
//  Bills
//
//  Created by José Carlos Estela Anguita on 26/05/2020.
//

import UI
import CoreFoundationLib

class BillEmittersManualPaymentDateFieldView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var textField: WithoutTitleLisboaTextField!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setupWithDate(_ date: String) {
        self.textField.configure(with: nil, title: date, extraInfo: nil)
        self.textField.updateTextFieldColor(separator: .lightSanGray, borders: .lightGray40)
        self.textField.field.autocorrectionType = .no
        self.textField.field.spellCheckingType = .no
        self.textField.fieldValue = date
    }
}

private extension BillEmittersManualPaymentDateFieldView {
    
    func setup() {
        self.titleLabel.textColor = UIColor.lisboaGray
        self.titleLabel.text = localized("receiptsAndTaxes_label_collectionDate")
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 14)
        self.textField.isUserInteractionEnabled = false
        self.textField.field.isEnabled = false
        self.textField.accessibilityIdentifier = "areaInputText"
        self.titleLabel.accessibilityIdentifier = "receiptsAndTaxes_label_collectionDate"
    }
}
