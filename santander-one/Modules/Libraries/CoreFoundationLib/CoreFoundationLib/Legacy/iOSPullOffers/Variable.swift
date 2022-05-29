//
//  Variable.swift
//  IOS-Pull-Offers
//
//  Created by Carlos Pérez Pérez on 3/7/18.
//  Copyright © 2018 Carlos Pérez Pérez. All rights reserved.
//

public protocol Variable: Expression {
    var id: String? {get set}
    var value: Any? {get set}
    var type: VarType? {get set}
}

public enum VarType: Int {
    case logical = 0
    case arithmetical = 1
    case string = 2
    case date = 3
    case variable = 4
    case array = 5
}
