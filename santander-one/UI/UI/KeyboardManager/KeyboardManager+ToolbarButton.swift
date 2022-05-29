//
//  KeyboardManager+ToolbarButton.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 17/07/2020.
//

import Foundation

extension KeyboardManager {
    
    public class ToolbarButton {
        
        let title: String
        let accessibilityIdentifier: String?
        let action: (EditText) -> Void
        let actionType: Action
        
        public init(title: String, accessibilityIdentifier: String?, action: @escaping (EditText) -> Void, actionType: Action = .continueAction) {
            self.title = title
            self.accessibilityIdentifier = accessibilityIdentifier
            self.action = action
            self.actionType = actionType
        }
    }
    
    public enum Action {
        case acceptAction
        case continueAction
    }
}
