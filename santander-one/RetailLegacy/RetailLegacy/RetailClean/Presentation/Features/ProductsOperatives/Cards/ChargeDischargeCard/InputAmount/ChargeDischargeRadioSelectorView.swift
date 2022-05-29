import UIKit

protocol OnRadioItemTextChangeDelegate: class {
    func textDidChange(tag: Int, text: String?)
}

class ChargeDischargeRadioSelectorView: RadioSelectableItem<OrderTypeItemType> {
    override var insets: UIEdgeInsets {
        switch type {
        case .empty:
            return .zero
        case .amount:
            return UIEdgeInsets(top: 8, left: 45, bottom: 23, right: 13)
        }
    }
    
    override var height: CGFloat {
        return 50.0
    }
    
    override var field: UITextField? {
        if let created = _field {
            return created
        }

        switch type {
        case .amount(let placeholder, let value):
            let field = RadioSelectableItemConstants.defaultNumericField
            field.text = value
            field.textFormatMode = .defaultCurrency(12, 2)
            field.delegate = field.parser
            field.setOnPlaceholder(localizedStylableText: placeholder)
            
            return field

        default:
            return nil
        }
    }
    
    override var auxiliaryImage: UIImage? {
        return nil
    }
}
