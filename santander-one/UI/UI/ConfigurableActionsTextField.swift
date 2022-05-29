//
//  ConfigurableActionsTextField.swift
//  UI
//
//  Created by alvola on 05/03/2020.
//

import UIKit

public class ConfigurableActionsTextField: UITextField {
    var disabledActions: [TextFieldActions]?
    var rightViewOffset: (x: CGFloat, y: CGFloat)?
    public var pasteCompletion: (() -> Void)?
    
    public override func paste(_ sender: Any?) {
        super.paste(sender)
        self.pasteCompletion?()
    }
    
    public func setDisabledActions(_ actions: [TextFieldActions]?) {
        disabledActions = actions
    }
    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if (disabledActions ?? []).contains(where: { $0.associatedStandardEditAction() == action }) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let originalRect = super.clearButtonRect(forBounds: bounds)
        guard let offset = rightViewOffset else { return originalRect }
        return originalRect.offsetBy(dx: offset.x, dy: offset.y)
    }
}

public enum TextFieldActions {
    case cut
    case copy
    case paste
    case select
    case selectAll
    case delete
    case makeTextWritingDirectionLeftToRight
    case makeTextWritingDirectionRightToLeft
    case toggleBoldface
    case toggleItalics
    case toggleUnderline
    case increaseSize
    case decreaseSize
    
    public static var usuallyDisabledActions: [TextFieldActions] {
        return [.cut, .paste, .copy, .select, .selectAll]
    }
    
    public static var keyDisabledActions: [TextFieldActions] {
        return [.cut, .copy, .select, .selectAll]
    }
    
    public func associatedStandardEditAction() -> Selector {
        switch self {
        case .cut:
            return #selector(UIResponderStandardEditActions.cut(_:))
        case .copy:
            return #selector(UIResponderStandardEditActions.copy(_:))
        case .paste:
            return #selector(UIResponderStandardEditActions.paste(_:))
        case .select:
            return #selector(UIResponderStandardEditActions.select(_:))
        case .selectAll:
            return #selector(UIResponderStandardEditActions.selectAll(_:))
        case .delete:
            return #selector(UIResponderStandardEditActions.delete(_:))
        case .makeTextWritingDirectionLeftToRight:
            return #selector(UIResponderStandardEditActions.makeTextWritingDirectionLeftToRight(_:))
        case .makeTextWritingDirectionRightToLeft:
            return #selector(UIResponderStandardEditActions.makeTextWritingDirectionRightToLeft(_:))
        case .toggleBoldface:
            return #selector(UIResponderStandardEditActions.toggleBoldface(_:))
        case .toggleItalics:
            return #selector(UIResponderStandardEditActions.toggleItalics(_:))
        case .toggleUnderline:
            return #selector(UIResponderStandardEditActions.toggleUnderline(_:))
        case .increaseSize:
            return #selector(UIResponderStandardEditActions.increaseSize(_:))
        case .decreaseSize:
            return #selector(UIResponderStandardEditActions.decreaseSize(_:))
        }
    }
}
