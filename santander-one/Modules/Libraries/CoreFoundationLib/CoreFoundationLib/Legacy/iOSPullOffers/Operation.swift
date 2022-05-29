//
//  Operation.swift
//  IOS-Pull-Offers
//
//  Created by Carlos Pérez Pérez on 3/7/18.
//  Copyright © 2018 Carlos Pérez Pérez. All rights reserved.
//

public protocol Operation: Expression {
    var lh: Expression? {get set}
    var rh: Expression? {get set}
    var oper: Operator? {get set}
    
    func setLh(lh: Expression)
    func setRh(rh: Expression)
    func setOperator(oper: Operator)
    func hasAllVariablesNeeded(knownVariables: [Variable]) -> Bool
    func resolve(variables: [Variable]) throws -> PullOfferResult
    
    func printFullTree()
    func printTree(level: Int?) -> String
}
