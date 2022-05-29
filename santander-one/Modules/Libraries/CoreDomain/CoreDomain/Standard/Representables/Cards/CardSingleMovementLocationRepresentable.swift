//
//  CardSingleMovementLocationRepresentable.swift
//  CoreDomain
//
//  Created by Gloria Cano López on 5/4/22.
//

public protocol CardSingleCardMovementRepresentable {
    var location: CardMovementLocationRepresentable { get }
    var status: CardMovementLocationUseType { get }
}

public enum CardMovementLocationUseType {
    case locatedMovement
    case notLocatedMovement
    case onlineMovement
    case serviceError
    case neverLocalizable
}

