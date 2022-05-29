//
//  Engine.swift
//  IOS-Pull-Offers
//
//  Created by Carlos Pérez Pérez on 3/7/18.
//  Copyright © 2018 Carlos Pérez Pérez. All rights reserved.
//

public protocol Engine {
    func isValid(expression: Any) -> Bool
}

public protocol LexicalEngine: Engine {
    var validCharsForVariable: String { get }
    var validCharsForConstant: String { get }
    var validCharsForOperators: String { get }
    
    func performLexicalAnalysis() throws -> [Token]
}

public protocol SintacticalEngine: Engine {
    var validCharsForVariable: String { get }
    var validCharsForConstant: String { get }
    var validCharsForOperators: String { get }
    
    func performSintacticalAnalysis() throws -> Expression?
}

public protocol SemanticalEngine: Engine {
    var variablesNamesArray: [String] { get }
    var variablesValuesArray: [Any] { get }
    
    func performSemanticalAnalysis(with node: Expression) throws -> PullOfferResult
    func evaluate(rule: Expression, varsIds: [Variable], varsValues: [Variable]) throws -> PullOfferResult
}
