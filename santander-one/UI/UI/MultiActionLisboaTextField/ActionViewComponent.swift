//
//  ActionViewComponent.swift
//  UI
//
//  Created by Boris Chirino Fernandez on 30/12/2020.
//
public enum ActionViewComponentType {
    case contactList
    case addContact
}

public typealias ViewAction = () -> Void

public final class ActionViewComponent {
    let view: UIView
    let action: ViewAction
    let componentType: ActionViewComponentType
    public init(view: UIView, type: ActionViewComponentType, action: @escaping ViewAction) {
        self.view = view
        self.action = action
        self.componentType = type
    }
    
    public func setViewDisabled(_ disabled: Bool) {
        self.view.isUserInteractionEnabled = !disabled
        self.view.alpha = disabled ? 0.8 : 1.0
    }
}
