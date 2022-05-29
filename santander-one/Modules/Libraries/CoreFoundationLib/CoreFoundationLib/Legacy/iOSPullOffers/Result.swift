//
//  Result.swift
//  IOS-Pull-Offers
//
//  Created by Carlos Pérez Pérez on 4/6/18.
//  Copyright © 2018 Carlos Pérez Pérez. All rights reserved.
//

public enum Decission {
    case valid
    case notValid
    case error
}

public struct PullOfferResult {
    public var idRule: String
    public var result: Decission
    public var resultError: String?
    public var resultValue: Variable?
    
    public init(idRule: String, result: Decission, resultError: String?, resultValue: Variable?) {
        self.idRule = idRule
        self.result = result
        self.resultError = resultError
        self.resultValue = resultValue
    }
}
