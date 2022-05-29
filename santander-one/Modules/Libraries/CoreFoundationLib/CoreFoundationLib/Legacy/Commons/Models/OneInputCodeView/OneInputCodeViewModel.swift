//
//  OneInputCodeViewModel.swift
//  CoreFoundationLib
//
//  Created by Angel Abad Perez on 2/3/22.
//

public struct OneInputCodeViewModel {
    public var isAlphanumeric: Bool
    public let hiddenCharacters: Bool
    public let enabledChangeVisibility: Bool
    public let itemsCount: Int
    public let requestedPositions: RequestedPositions
    
    public init(isAlphanumeric: Bool = false,
                hiddenCharacters: Bool,
                enabledChangeVisibility: Bool,
                itemsCount: Int,
                requestedPositions: RequestedPositions) {
        self.isAlphanumeric = isAlphanumeric
        self.hiddenCharacters = hiddenCharacters
        self.enabledChangeVisibility = enabledChangeVisibility
        self.itemsCount = itemsCount
        self.requestedPositions = requestedPositions
    }
    
    public enum RequestedPositions {
        case all
        case positions([Int])

        public func isRequestedPosition(position: Int) -> Bool {
            switch self {
            case .all:
                return true
            case .positions(let positions):
                return positions.contains(where: { $0 - 1 == position })
            }
        }
    }
}
