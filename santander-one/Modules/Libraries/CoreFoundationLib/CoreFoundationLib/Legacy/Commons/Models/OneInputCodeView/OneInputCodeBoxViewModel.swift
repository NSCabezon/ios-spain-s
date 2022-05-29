//
//  OneInputCodeBoxViewModel.swift
//  CoreFoundationLib
//
//  Created by Angel Abad Perez on 2/3/22.
//

public struct OneInputCodeBoxViewModel {
    public let itemsCount: Int
    public let position: Int
    public let requested: Bool
    public let hidden: Bool
    
    public init(itemsCount: Int,
                position: Int,
                requested: Bool,
                hidden: Bool) {
        self.itemsCount = itemsCount
        self.position = position
        self.requested = requested
        self.hidden = hidden
    }
}

public enum OneInputCodeBoxViewPosition {
    case first
    case middle
    case last
}

public enum OneInputCodeBoxViewStatus {
    case deselected
    case selected
    case error
}
