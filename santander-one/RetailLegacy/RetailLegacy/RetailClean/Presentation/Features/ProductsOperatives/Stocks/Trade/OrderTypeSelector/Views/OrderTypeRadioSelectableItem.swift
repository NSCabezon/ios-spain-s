import UIKit
import UI

class OrderTypeRadioSelectableItem: RadioSelectableItem<OrderTypeItemType> {
    override var insets: UIEdgeInsets {
        switch type {
        case .empty:
            return .zero
        case .amount:
            return UIEdgeInsets(top: 8, left: 45, bottom: 23, right: 13)
        }
    }
    
    override var height: CGFloat {
        switch type {
        case .empty:
            return 0.0
        case .amount:
            return 50.0
        }
    }
    
    override var field: UITextField? {
        if let created = _field {
            return created
        }
        let newField: UITextField?
        switch type {
        case .empty:
            return nil
        case .amount(let placeholder, let value):
            let field = RadioSelectableItemConstants.defaultNumericField
            field.text = value
            field.textFormatMode = .defaultCurrency(12, 4)
            field.delegate = field.parser
            field.setOnPlaceholder(localizedStylableText: placeholder)
            
            newField = field
        }
        return newField
    }
    
    override var auxiliaryImage: UIImage? {
        return Assets.image(named: "icnInfoGrayBig")
    }
}
