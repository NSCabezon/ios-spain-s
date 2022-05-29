//
//  RuleRepresentable.swift
//  CoreDomain
//
//  Created by José Carlos Estela Anguita on 20/12/21.
//

import Foundation

public protocol RuleRepresentable {
    var identifier: String { get }
    var expression: String { get }
}
