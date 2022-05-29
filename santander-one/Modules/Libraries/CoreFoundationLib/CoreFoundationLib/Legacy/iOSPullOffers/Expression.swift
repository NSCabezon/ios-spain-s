//
//  Expression.swift
//  IOS-Pull-Offers
//
//  Created by Carlos Pérez Pérez on 3/7/18.
//  Copyright © 2018 Carlos Pérez Pérez. All rights reserved.
//

public protocol Expression {
    var rawExpression: String? {get set}
    var parentExpression: Expression? {get set}
    
    func getTopParent() -> Expression
    func getNodeVariables() -> [Variable]
}

public enum Bracket: Character {
    case Left = "("
    case Right = ")"
    case LeftCurly = "{"
    case RightCurly = "}"
    case LeftSquare = "["
    case RightSquare = "]"
    
    public var matchingOpen: Bracket? {
        switch self {
        case .Right:        return .Left
        case .RightCurly:   return .LeftCurly
        case .RightSquare:  return .LeftSquare
        default:            return nil
        }
    }
}
