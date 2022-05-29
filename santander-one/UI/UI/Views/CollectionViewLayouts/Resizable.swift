//
//  Resizable.swift
//  UI
//
//  Created by Juan Carlos López Robles on 11/25/19.
//

import Foundation

public protocol ResizableStateDelegate: AnyObject {
    func didStateChange(_ state: ResizableState)
}

public enum ResizableState {
    case expanded
    case colapsed
}

public protocol Resizable {
    var state: ResizableState { get set }
    func getExpandedHeight() -> CGFloat
    func getCollapsedHeight() -> CGFloat
    func getHeightForState() -> CGFloat
    func getOfferHeight() -> CGFloat
    mutating func toggleState()
}

public extension Resizable {

    func getHeightForState() -> CGFloat {
        switch state {
        case .colapsed:
            return getCollapsedHeight() + getOfferHeight()
        case .expanded:
            return getExpandedHeight() + getOfferHeight()
        }
    }
}
