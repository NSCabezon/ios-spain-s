//
//  UITableViewPublisher+extension .swift
//  UI
//
//  Created by Juan Carlos López Robles on 3/23/22.
//

import Foundation
import OpenCombine

public extension UITableView {
    var delegatePublisher: AnyPublisher<UITableViewDelegateState, Never>? {
        guard let uiReactiveDelegate = delegate as? UIReactiveTableViewDelegate else {
            return nil
        }
        return uiReactiveDelegate.statePublisher
    }
}
