//
//  ActionComponentGestureRecognizer.swift
//  UI
//
//  Created by Boris Chirino Fernandez on 30/12/2020.
//

import Foundation

public class ActionComponentGestureRecognizer: UITapGestureRecognizer {
    public let actionComponent: ActionViewComponent
    public init(target: Any?, action: Selector?, component: ActionViewComponent) {
        self.actionComponent = component
        super.init(target: target, action: action)
    }
}
